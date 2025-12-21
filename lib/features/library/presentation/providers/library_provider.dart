import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/library_repository.dart';
import '../../../../data/models/library_item_model.dart';

/// Library repository provider
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository();
});

/// Library items provider
final libraryItemsProvider = StreamProvider.family<List<LibraryItemModel>, String?>((ref, status) {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getLibraryItemsStream(status: status);
});

/// Library item by book ID provider
final libraryItemByBookIdProvider = FutureProvider.family<LibraryItemModel?, String>((ref, bookId) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getLibraryItemByBookId(bookId);
});

/// Library controller provider
final libraryControllerProvider = Provider<LibraryController>((ref) {
  return LibraryController(ref.read(libraryRepositoryProvider));
});

class LibraryController {
  final LibraryRepository _repository;
  
  LibraryController(this._repository);
  
  Future<void> addToLibrary(String bookId, {String? status}) async {
    await _repository.addToLibrary(bookId, status: status);
  }
  
  Future<void> removeFromLibrary(String bookId) async {
    await _repository.removeFromLibrary(bookId);
  }
  
  Future<void> updateReadingProgress({
    required String bookId,
    required int currentPage,
    required int currentChapter,
    required double progress,
  }) async {
    await _repository.updateReadingProgress(
      bookId: bookId,
      currentPage: currentPage,
      currentChapter: currentChapter,
      progress: progress,
    );
  }
  
  Future<void> updateBookStatus(String bookId, String status) async {
    await _repository.updateBookStatus(bookId, status);
  }
}

