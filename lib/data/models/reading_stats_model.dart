import 'package:cloud_firestore/cloud_firestore.dart';

/// Reading statistics model
class ReadingStatsModel {
  final String userId;
  final int totalPagesRead;
  final int totalChaptersRead;
  final int totalBooksCompleted;
  final int totalReadingTimeMinutes;
  final int currentStreak;
  final DateTime? lastReadingDate;
  final Map<String, int> dailyStats; // Date -> minutes read
  final Map<String, int> weeklyStats; // Week -> pages read
  final Map<String, int> monthlyStats; // Month -> pages read
  final DateTime updatedAt;
  
  ReadingStatsModel({
    required this.userId,
    this.totalPagesRead = 0,
    this.totalChaptersRead = 0,
    this.totalBooksCompleted = 0,
    this.totalReadingTimeMinutes = 0,
    this.currentStreak = 0,
    this.lastReadingDate,
    this.dailyStats = const {},
    this.weeklyStats = const {},
    this.monthlyStats = const {},
    required this.updatedAt,
  });
  
  // Create from Firestore document
  factory ReadingStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReadingStatsModel(
      userId: doc.id,
      totalPagesRead: data['totalPagesRead'] ?? 0,
      totalChaptersRead: data['totalChaptersRead'] ?? 0,
      totalBooksCompleted: data['totalBooksCompleted'] ?? 0,
      totalReadingTimeMinutes: data['totalReadingTimeMinutes'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      lastReadingDate: (data['lastReadingDate'] as Timestamp?)?.toDate(),
      dailyStats: Map<String, int>.from(data['dailyStats'] ?? {}),
      weeklyStats: Map<String, int>.from(data['weeklyStats'] ?? {}),
      monthlyStats: Map<String, int>.from(data['monthlyStats'] ?? {}),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'totalPagesRead': totalPagesRead,
      'totalChaptersRead': totalChaptersRead,
      'totalBooksCompleted': totalBooksCompleted,
      'totalReadingTimeMinutes': totalReadingTimeMinutes,
      'currentStreak': currentStreak,
      'lastReadingDate': lastReadingDate != null ? Timestamp.fromDate(lastReadingDate!) : null,
      'dailyStats': dailyStats,
      'weeklyStats': weeklyStats,
      'monthlyStats': monthlyStats,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
  
  // Create copy with updated fields
  ReadingStatsModel copyWith({
    String? userId,
    int? totalPagesRead,
    int? totalChaptersRead,
    int? totalBooksCompleted,
    int? totalReadingTimeMinutes,
    int? currentStreak,
    DateTime? lastReadingDate,
    Map<String, int>? dailyStats,
    Map<String, int>? weeklyStats,
    Map<String, int>? monthlyStats,
    DateTime? updatedAt,
  }) {
    return ReadingStatsModel(
      userId: userId ?? this.userId,
      totalPagesRead: totalPagesRead ?? this.totalPagesRead,
      totalChaptersRead: totalChaptersRead ?? this.totalChaptersRead,
      totalBooksCompleted: totalBooksCompleted ?? this.totalBooksCompleted,
      totalReadingTimeMinutes: totalReadingTimeMinutes ?? this.totalReadingTimeMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      dailyStats: dailyStats ?? this.dailyStats,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      monthlyStats: monthlyStats ?? this.monthlyStats,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

