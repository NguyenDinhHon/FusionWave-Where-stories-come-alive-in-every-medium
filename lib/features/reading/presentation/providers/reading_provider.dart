import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/chapter_repository.dart';
import '../../../../data/repositories/library_repository.dart';
import '../../../../data/models/chapter_model.dart';

/// Chapter repository provider
final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  return ChapterRepository();
});


/// Library repository provider
final libraryRepositoryForReadingProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository();
});

/// Cache for chapters by book ID (keeps chapters in memory)
class ChaptersCache {
  final Map<String, List<ChapterModel>> _cache = {};
  
  void setChapters(String bookId, List<ChapterModel> chapters) {
    _cache[bookId] = chapters;
  }
  
  List<ChapterModel>? getChapters(String bookId) {
    return _cache[bookId];
  }
  
  bool hasChapters(String bookId) {
    return _cache.containsKey(bookId) && _cache[bookId]!.isNotEmpty;
  }
  
  Map<String, List<ChapterModel>> get all => Map.unmodifiable(_cache);
}

final _chaptersCacheProvider = Provider<ChaptersCache>((ref) {
  return ChaptersCache();
});

/// Public provider to check if chapters are cached for a book
final chaptersCacheCheckProvider = Provider.family<bool, String>((ref, bookId) {
  final cache = ref.watch(_chaptersCacheProvider);
  return cache.hasChapters(bookId);
});

/// Chapters by book ID provider with cache support
final chaptersByBookIdProvider = FutureProvider.family<List<ChapterModel>, String>((ref, bookId) async {
  // Check cache first - if chapters exist in cache, return immediately
  final cache = ref.read(_chaptersCacheProvider);
  final cachedChapters = cache.getChapters(bookId);
  if (cachedChapters != null && cachedChapters.isNotEmpty) {
    // Return cached chapters immediately (no loading!)
    return cachedChapters;
  }
  
  // Load from repository if not in cache
  final repository = ref.watch(chapterRepositoryProvider);
  final chapters = await repository.getChaptersByBookId(bookId);
  
  // Update cache for future use
  cache.setChapters(bookId, chapters);
  
  return chapters;
});

/// Chapter by ID provider with cache support
final chapterByIdProvider = FutureProvider.family<ChapterModel?, String>((ref, chapterId) async {
  // Try to find in cache first
  final cache = ref.read(_chaptersCacheProvider);
  for (var chapters in cache.all.values) {
    try {
      final chapter = chapters.firstWhere((c) => c.id == chapterId);
      // Found in cache - return immediately
      return chapter;
    } catch (e) {
      // Not found in this book's chapters, continue searching
      continue;
    }
  }
  
  // Load from repository if not in cache
  final repository = ref.watch(chapterRepositoryProvider);
  return repository.getChapterById(chapterId);
});

/// Reading controller provider
final readingControllerProvider = Provider<ReadingController>((ref) {
  return ReadingController(
    ref.read(chapterRepositoryProvider),
    ref.read(libraryRepositoryForReadingProvider),
  );
});

class ReadingController {
  final ChapterRepository _chapterRepository;
  final LibraryRepository _libraryRepository;
  
  ReadingController(this._chapterRepository, this._libraryRepository);
  
  Future<void> updateReadingProgress({
    required String bookId,
    required int currentPage,
    required int currentChapter,
    required int totalPages,
    required int totalChapters,
  }) async {
    final progress = totalChapters > 0 
        ? currentChapter / totalChapters 
        : (totalPages > 0 ? currentPage / totalPages : 0.0);
    
    await _libraryRepository.updateReadingProgress(
      bookId: bookId,
      currentPage: currentPage,
      currentChapter: currentChapter,
      progress: progress,
    );
  }
  
  Future<ChapterModel?> getNextChapter(String bookId, int currentChapterNumber) async {
    return _chapterRepository.getNextChapter(bookId, currentChapterNumber);
  }
  
  Future<ChapterModel?> getPreviousChapter(String bookId, int currentChapterNumber) async {
    return _chapterRepository.getPreviousChapter(bookId, currentChapterNumber);
  }
}

