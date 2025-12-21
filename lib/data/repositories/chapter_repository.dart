import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firebase_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/chapter_model.dart';
import '../../core/utils/logger.dart';

/// Chapter repository
class ChapterRepository {
  final FirebaseService _firebaseService = FirebaseService();
  
  FirebaseFirestore get _firestore => _firebaseService.firestore;
  
  // Get chapters for a book
  Future<List<ChapterModel>> getChaptersByBookId(
    String bookId, {
    int limit = AppConstants.chaptersPerPage,
  }) async {
    try {
      // Avoid composite index by fetching and sorting in memory
      final snapshot = await _firestore
          .collection(AppConstants.chaptersCollection)
          .where('bookId', isEqualTo: bookId)
          .where('isPublished', isEqualTo: true)
          .limit(limit * 2) // Get more to sort
          .get();
      
      final chapters = snapshot.docs
          .map((doc) => ChapterModel.fromFirestore(doc))
          .toList();
      
      // Sort by chapterNumber ascending
      chapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
      
      return chapters.take(limit).toList();
    } catch (e) {
      AppLogger.error('Get chapters by book ID error', error: e);
      rethrow;
    }
  }
  
  // Get chapter by ID
  Future<ChapterModel?> getChapterById(String chapterId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.chaptersCollection)
          .doc(chapterId)
          .get();
      
      if (!doc.exists) return null;
      
      return ChapterModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.error('Get chapter by ID error', error: e);
      rethrow;
    }
  }
  
  // Get chapter by book ID and chapter number
  Future<ChapterModel?> getChapterByNumber(
    String bookId,
    int chapterNumber,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.chaptersCollection)
          .where('bookId', isEqualTo: bookId)
          .where('chapterNumber', isEqualTo: chapterNumber)
          .where('isPublished', isEqualTo: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      return ChapterModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      AppLogger.error('Get chapter by number error', error: e);
      rethrow;
    }
  }
  
  // Get next chapter
  Future<ChapterModel?> getNextChapter(String bookId, int currentChapterNumber) async {
    try {
      return getChapterByNumber(bookId, currentChapterNumber + 1);
    } catch (e) {
      AppLogger.error('Get next chapter error', error: e);
      rethrow;
    }
  }
  
  // Get previous chapter
  Future<ChapterModel?> getPreviousChapter(String bookId, int currentChapterNumber) async {
    try {
      if (currentChapterNumber <= 1) return null;
      return getChapterByNumber(bookId, currentChapterNumber - 1);
    } catch (e) {
      AppLogger.error('Get previous chapter error', error: e);
      rethrow;
    }
  }

  // Create chapter
  Future<ChapterModel> createChapter(ChapterModel chapter) async {
    try {
      await _firestore
          .collection(AppConstants.chaptersCollection)
          .doc(chapter.id)
          .set(chapter.toFirestore());
      return chapter;
    } catch (e) {
      AppLogger.error('Create chapter error', error: e);
      rethrow;
    }
  }

  // Update chapter
  Future<void> updateChapter(ChapterModel chapter) async {
    try {
      await _firestore
          .collection(AppConstants.chaptersCollection)
          .doc(chapter.id)
          .update(chapter.toFirestore());
    } catch (e) {
      AppLogger.error('Update chapter error', error: e);
      rethrow;
    }
  }

  // Delete chapter
  Future<void> deleteChapter(String chapterId) async {
    try {
      await _firestore
          .collection(AppConstants.chaptersCollection)
          .doc(chapterId)
          .delete();
    } catch (e) {
      AppLogger.error('Delete chapter error', error: e);
      rethrow;
    }
  }

  // Get all chapters for a book (including unpublished) for admin
  Future<List<ChapterModel>> getAllChaptersByBookId(String bookId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.chaptersCollection)
          .where('bookId', isEqualTo: bookId)
          .get();

      final chapters = snapshot.docs
          .map((doc) => ChapterModel.fromFirestore(doc))
          .toList();

      // Sort by chapterNumber ascending
      chapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));

      return chapters;
    } catch (e) {
      AppLogger.error('Get all chapters by book ID error', error: e);
      rethrow;
    }
  }
}

