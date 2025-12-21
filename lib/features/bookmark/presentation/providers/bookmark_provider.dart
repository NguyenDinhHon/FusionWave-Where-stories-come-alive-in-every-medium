import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/bookmark_repository.dart';
import '../../../../data/models/bookmark_model.dart';

/// Bookmark repository provider
final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepository();
});

/// Bookmarks by book ID provider
final bookmarksByBookIdProvider = StreamProvider.family<List<BookmarkModel>, String>((ref, bookId) {
  final repository = ref.watch(bookmarkRepositoryProvider);
  return repository.getBookmarksByBookId(bookId);
});

/// User bookmarks provider
final userBookmarksProvider = StreamProvider<List<BookmarkModel>>((ref) {
  final repository = ref.watch(bookmarkRepositoryProvider);
  return repository.getUserBookmarks();
});

/// Bookmark controller provider
final bookmarkControllerProvider = Provider<BookmarkController>((ref) {
  return BookmarkController(ref.read(bookmarkRepositoryProvider));
});

class BookmarkController {
  final BookmarkRepository _repository;
  
  BookmarkController(this._repository);
  
  Future<BookmarkModel> addBookmark({
    required String bookId,
    required String chapterId,
    required int chapterNumber,
    int? pageNumber,
    String? note,
    String? highlightedText,
  }) async {
    return await _repository.addBookmark(
      bookId: bookId,
      chapterId: chapterId,
      chapterNumber: chapterNumber,
      pageNumber: pageNumber,
      note: note,
      highlightedText: highlightedText,
    );
  }
  
  Future<void> deleteBookmark(String bookmarkId) async {
    await _repository.deleteBookmark(bookmarkId);
  }
  
  Future<void> updateBookmark(String bookmarkId, {
    String? note,
    String? highlightedText,
  }) async {
    await _repository.updateBookmark(bookmarkId, note: note, highlightedText: highlightedText);
  }
  
  Future<BookmarkModel?> getBookmarkAtPosition({
    required String bookId,
    required String chapterId,
    int? pageNumber,
  }) async {
    return await _repository.getBookmarkAtPosition(
      bookId: bookId,
      chapterId: chapterId,
      pageNumber: pageNumber,
    );
  }
}

