import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firebase_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/reading_stats_model.dart';
import '../../core/utils/logger.dart';

/// Reading statistics repository
class StatsRepository {
  final FirebaseService _firebaseService = FirebaseService();
  
  FirebaseFirestore get _firestore => _firebaseService.firestore;
  String? get _currentUserId => _firebaseService.currentUserId;
  
  // Get reading stats
  Future<ReadingStatsModel?> getReadingStats() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final doc = await _firestore
          .collection(AppConstants.readingStatsCollection)
          .doc(_currentUserId)
          .get();
      
      if (!doc.exists) {
        // Create initial stats
        return _createInitialStats();
      }
      
      return ReadingStatsModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.error('Get reading stats error', error: e);
      rethrow;
    }
  }
  
  // Create initial stats
  Future<ReadingStatsModel> _createInitialStats() async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }
    
    final stats = ReadingStatsModel(
      userId: _currentUserId!,
      updatedAt: DateTime.now(),
    );
    
    await _firestore
        .collection(AppConstants.readingStatsCollection)
        .doc(_currentUserId)
        .set(stats.toFirestore());
    
    return stats;
  }
  
  // Update reading stats
  Future<void> updateReadingStats({
    int? pagesRead,
    int? chaptersRead,
    int? readingTimeMinutes,
    bool? chapterCompleted,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final now = DateTime.now();
      final today = _formatDate(now);
      final week = _formatWeek(now);
      final month = _formatMonth(now);
      
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (pagesRead != null && pagesRead > 0) {
        updates['totalPagesRead'] = FieldValue.increment(pagesRead);
        updates['dailyStats.$today'] = FieldValue.increment(pagesRead);
        updates['weeklyStats.$week'] = FieldValue.increment(pagesRead);
        updates['monthlyStats.$month'] = FieldValue.increment(pagesRead);
      }
      
      if (chaptersRead != null && chaptersRead > 0) {
        updates['totalChaptersRead'] = FieldValue.increment(chaptersRead);
      }
      
      if (readingTimeMinutes != null && readingTimeMinutes > 0) {
        updates['totalReadingTimeMinutes'] = FieldValue.increment(readingTimeMinutes);
      }
      
      if (chapterCompleted == true) {
        updates['totalBooksCompleted'] = FieldValue.increment(1);
      }
      
      // Update streak
      final stats = await getReadingStats();
      if (stats != null) {
        final newStreak = _calculateStreak(stats.lastReadingDate, now);
        if (newStreak > stats.currentStreak) {
          updates['currentStreak'] = newStreak;
        }
        updates['lastReadingDate'] = Timestamp.fromDate(now);
      }
      
      await _firestore
          .collection(AppConstants.readingStatsCollection)
          .doc(_currentUserId)
          .update(updates);
      
      AppLogger.info('Reading stats updated');
    } catch (e) {
      AppLogger.error('Update reading stats error', error: e);
      rethrow;
    }
  }
  
  // Calculate reading streak
  int _calculateStreak(DateTime? lastReadingDate, DateTime now) {
    if (lastReadingDate == null) return 1;
    
    final difference = now.difference(lastReadingDate).inDays;
    
    if (difference == 0) {
      // Same day, maintain streak
      return 1;
    } else if (difference == 1) {
      // Consecutive day, increment streak
      return 2;
    } else {
      // Streak broken, reset to 1
      return 1;
    }
  }
  
  // Format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  // Format week as YYYY-WW
  String _formatWeek(DateTime date) {
    final week = ((date.difference(DateTime(date.year, 1, 1)).inDays) / 7).floor() + 1;
    return '${date.year}-W${week.toString().padLeft(2, '0')}';
  }
  
  // Format month as YYYY-MM
  String _formatMonth(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }
  
  // Get reading stats stream (realtime)
  Stream<ReadingStatsModel?> getReadingStatsStream() {
    if (_currentUserId == null) {
      return Stream.value(null);
    }
    
    return _firestore
        .collection(AppConstants.readingStatsCollection)
        .doc(_currentUserId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return ReadingStatsModel.fromFirestore(snapshot);
    });
  }
}

