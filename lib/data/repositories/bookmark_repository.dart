import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firebase_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/bookmark_model.dart';
import '../../core/utils/logger.dart';

/// Bookmark repository
class BookmarkRepository {
  final FirebaseService _firebaseService = FirebaseService();
  
  FirebaseFirestore get _firestore => _firebaseService.firestore;
  FirebaseAuth get _auth => _firebaseService.auth;
  
  String? get _currentUserId => _auth.currentUser?.uid;
  
  // Add bookmark
  Future<BookmarkModel> addBookmark({
    required String bookId,
    required String chapterId,
    required int chapterNumber,
    int? pageNumber,
    String? note,
    String? highlightedText,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User must be logged in to add bookmark');
      }
      
      final bookmark = BookmarkModel(
        id: '', // Will be set by Firestore
        userId: _currentUserId!,
        bookId: bookId,
        chapterId: chapterId,
        chapterNumber: chapterNumber,
        pageNumber: pageNumber,
        note: note,
        highlightedText: highlightedText,
        createdAt: DateTime.now(),
      );
      
      final docRef = await _firestore
          .collection(AppConstants.bookmarksCollection)
          .add(bookmark.toFirestore());
      
      AppLogger.info('Bookmark added: ${docRef.id}');
      return bookmark.copyWith(id: docRef.id);
    } catch (e) {
      AppLogger.error('Add bookmark error', error: e);
      rethrow;
    }
  }
  
  // Get bookmarks by book ID
  Stream<List<BookmarkModel>> getBookmarksByBookId(String bookId) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(AppConstants.bookmarksCollection)
        .where('userId', isEqualTo: _currentUserId)
        .where('bookId', isEqualTo: bookId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookmarkModel.fromFirestore(doc))
            .toList());
  }
  
  // Get all bookmarks for current user
  Stream<List<BookmarkModel>> getUserBookmarks() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(AppConstants.bookmarksCollection)
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookmarkModel.fromFirestore(doc))
            .toList());
  }
  
  // Get bookmark by ID
  Future<BookmarkModel?> getBookmarkById(String bookmarkId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.bookmarksCollection)
          .doc(bookmarkId)
          .get();
      
      if (!doc.exists) {
        return null;
      }
      
      return BookmarkModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.error('Get bookmark by ID error', error: e);
      rethrow;
    }
  }
  
  // Update bookmark
  Future<void> updateBookmark(String bookmarkId, {
    String? note,
    String? highlightedText,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (note != null) updates['note'] = note;
      if (highlightedText != null) updates['highlightedText'] = highlightedText;
      
      await _firestore
          .collection(AppConstants.bookmarksCollection)
          .doc(bookmarkId)
          .update(updates);
      
      AppLogger.info('Bookmark updated: $bookmarkId');
    } catch (e) {
      AppLogger.error('Update bookmark error', error: e);
      rethrow;
    }
  }
  
  // Delete bookmark
  Future<void> deleteBookmark(String bookmarkId) async {
    try {
      await _firestore
          .collection(AppConstants.bookmarksCollection)
          .doc(bookmarkId)
          .delete();
      
      AppLogger.info('Bookmark deleted: $bookmarkId');
    } catch (e) {
      AppLogger.error('Delete bookmark error', error: e);
      rethrow;
    }
  }
  
  // Check if bookmark exists at position
  Future<BookmarkModel?> getBookmarkAtPosition({
    required String bookId,
    required String chapterId,
    int? pageNumber,
  }) async {
    try {
      if (_currentUserId == null) return null;
      
      Query query = _firestore
          .collection(AppConstants.bookmarksCollection)
          .where('userId', isEqualTo: _currentUserId)
          .where('bookId', isEqualTo: bookId)
          .where('chapterId', isEqualTo: chapterId);
      
      if (pageNumber != null) {
        query = query.where('pageNumber', isEqualTo: pageNumber);
      }
      
      final snapshot = await query.limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      
      return BookmarkModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      AppLogger.error('Get bookmark at position error', error: e);
      return null;
    }
  }
}

