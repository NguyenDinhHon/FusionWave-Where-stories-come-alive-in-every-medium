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

/// Chapters by book ID provider
final chaptersByBookIdProvider = FutureProvider.family<List<ChapterModel>, String>((ref, bookId) async {
  final repository = ref.watch(chapterRepositoryProvider);
  return repository.getChaptersByBookId(bookId);
});

/// Chapter by ID provider
final chapterByIdProvider = FutureProvider.family<ChapterModel?, String>((ref, chapterId) async {
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

