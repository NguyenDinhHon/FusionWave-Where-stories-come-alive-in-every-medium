import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firebase_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/library_item_model.dart';
import '../../core/utils/logger.dart';

/// Library repository
class LibraryRepository {
  final FirebaseService _firebaseService = FirebaseService();

  FirebaseFirestore get _firestore => _firebaseService.firestore;
  String? get _currentUserId => _firebaseService.currentUserId;

  // Get user's library items
  Future<List<LibraryItemModel>> getLibraryItems({
    String? status,
    int limit = 50,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      Query query = _firestore
          .collection(AppConstants.libraryCollection)
          .doc(_currentUserId)
          .collection('books');

      // If status filter is provided, use where and sort in memory
      // Otherwise, use orderBy directly
      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status).limit(limit * 2);
      } else {
        query = query.orderBy('lastReadAt', descending: true).limit(limit);
      }

      final snapshot = await query.get();

      List<LibraryItemModel> items = snapshot.docs
          .map((doc) => LibraryItemModel.fromFirestore(doc))
          .toList();

      // Sort in memory if status filter was used
      if (status != null && status.isNotEmpty) {
        items.sort((a, b) {
          final aDate = a.lastReadAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.lastReadAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
        items = items.take(limit).toList();
      }

      return items;
    } catch (e) {
      AppLogger.error('Get library items error', error: e);
      rethrow;
    }
  }

  // Get library item by book ID
  Future<LibraryItemModel?> getLibraryItemByBookId(String bookId) async {
    try {
      if (_currentUserId == null) {
        return null;
      }

      final snapshot = await _firestore
          .collection(AppConstants.libraryCollection)
          .doc(_currentUserId)
          .collection('books')
          .where('bookId', isEqualTo: bookId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return LibraryItemModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      AppLogger.error('Get library item by book ID error', error: e);
      rethrow;
    }
  }

  // Add book to library
  Future<void> addToLibrary(String bookId, {String? status}) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final libraryItem = LibraryItemModel(
        id: bookId,
        userId: _currentUserId!,
        bookId: bookId,
        status: status ?? AppConstants.bookStatusWantToRead,
        addedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.libraryCollection)
          .doc(_currentUserId)
          .collection('books')
          .doc(bookId)
          .set(libraryItem.toFirestore());

      AppLogger.info('Book added to library: $bookId');
    } catch (e) {
      AppLogger.error('Add to library error', error: e);
      rethrow;
    }
  }

  // Remove book from library
  Future<void> removeFromLibrary(String bookId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(AppConstants.libraryCollection)
          .doc(_currentUserId)
          .collection('books')
          .doc(bookId)
          .delete();

      AppLogger.info('Book removed from library: $bookId');
    } catch (e) {
      AppLogger.error('Remove from library error', error: e);
      rethrow;
    }
  }

  // Update library item
  Future<void> updateLibraryItem(LibraryItemModel item) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(AppConstants.libraryCollection)
          .doc(_currentUserId)
          .collection('books')
          .doc(item.id)
          .update(item.toFirestore());

      AppLogger.info('Library item updated: ${item.id}');
    } catch (e) {
      AppLogger.error('Update library item error', error: e);
      rethrow;
    }
  }

  // Update reading progress
  Future<void> updateReadingProgress({
    required String bookId,
    required int currentPage,
    required int currentChapter,
    required double progress,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(AppConstants.libraryCollection)
          .doc(_currentUserId)
          .collection('books')
          .doc(bookId)
          .update({
            'currentPage': currentPage,
            'currentChapter': currentChapter,
            'progress': progress,
            'lastReadAt': FieldValue.serverTimestamp(),
            'status': AppConstants.bookStatusReading,
          });

      AppLogger.info('Reading progress updated for book: $bookId');
    } catch (e) {
      AppLogger.error('Update reading progress error', error: e);
      rethrow;
    }
  }

  // Update book status
  Future<void> updateBookStatus(String bookId, String status) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(AppConstants.libraryCollection)
          .doc(_currentUserId)
          .collection('books')
          .doc(bookId)
          .update({
            'status': status,
            'lastReadAt': FieldValue.serverTimestamp(),
          });

      AppLogger.info('Book status updated: $bookId -> $status');
    } catch (e) {
      AppLogger.error('Update book status error', error: e);
      rethrow;
    }
  }

  /// Mark a chapter as completed
  Future<void> markChapterCompleted({
    required String bookId,
    required String chapterId,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(AppConstants.libraryCollection)
          .doc(_currentUserId)
          .collection('books')
          .doc(bookId)
          .update({
            'completedChapters': FieldValue.arrayUnion([chapterId]),
            'lastReadAt': FieldValue.serverTimestamp(),
          });

      AppLogger.info(
        'Chapter $chapterId marked as completed for book: $bookId',
      );
    } catch (e) {
      AppLogger.error('Mark chapter completed error', error: e);
      rethrow;
    }
  }

  /// Check if all chapters completed and auto-update status
  Future<void> checkAndUpdateCompletionStatus({
    required String bookId,
    required int totalChapters,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore
          .collection(AppConstants.libraryCollection)
          .doc(_currentUserId)
          .collection('books')
          .doc(bookId)
          .get();

      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final completedChapters = List<String>.from(
        data['completedChapters'] ?? [],
      );

      // Auto-complete if all chapters done
      if (completedChapters.length >= totalChapters) {
        await updateBookStatus(bookId, AppConstants.bookStatusCompleted);
        AppLogger.info('Book $bookId auto-completed (all chapters done)');
      }
    } catch (e) {
      AppLogger.error('Check completion status error', error: e);
      rethrow;
    }
  }

  // Get library items stream (realtime)
  Stream<List<LibraryItemModel>> getLibraryItemsStream({String? status}) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    Query query = _firestore
        .collection(AppConstants.libraryCollection)
        .doc(_currentUserId!)
        .collection('books');

    // If status filter is provided, use where and sort in memory
    // Otherwise, use orderBy directly
    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    } else {
      query = query.orderBy('lastReadAt', descending: true);
    }

    return query.snapshots().map((snapshot) {
      List<LibraryItemModel> items = snapshot.docs
          .map((doc) => LibraryItemModel.fromFirestore(doc))
          .toList();

      // Sort in memory if status filter was used
      if (status != null && status.isNotEmpty) {
        items.sort((a, b) {
          final aDate = a.lastReadAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.lastReadAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
      }

      return items;
    });
  }
}
