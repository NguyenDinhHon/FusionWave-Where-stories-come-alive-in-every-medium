import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_stats_model.dart';

/// Local (on-device) reading statistics repository
class LocalStatsRepository {
  static const _storageKey = 'local_reading_stats';

  Future<ReadingStatsModel?> getReadingStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return null;
    try {
      final Map<String, dynamic> data = json.decode(raw) as Map<String, dynamic>;
      return ReadingStatsModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveReadingStats(ReadingStatsModel stats) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(stats.toJson());
    await prefs.setString(_storageKey, raw);
  }

  /// Update reading stats locally by applying increments/changes.
  Future<ReadingStatsModel> updateReadingStats({
    int? pagesRead,
    int? chaptersRead,
    int? readingTimeMinutes,
    bool? chapterCompleted,
  }) async {
    final now = DateTime.now();
    final existing = (await getReadingStats()) ?? ReadingStatsModel(userId: 'local', updatedAt: now);

    final daily = Map<String, int>.from(existing.dailyStats);
    final weekly = Map<String, int>.from(existing.weeklyStats);
    final monthly = Map<String, int>.from(existing.monthlyStats);

    String _fmtDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    String _fmtWeek(DateTime d) => '${d.year}-W${((d.difference(DateTime(d.year, 1, 1)).inDays) / 7).floor() + 1}'.padLeft(5, '0');
    String _fmtMonth(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

    final today = _fmtDate(now);
    final week = _fmtWeek(now);
    final month = _fmtMonth(now);

    var totalPages = existing.totalPagesRead;
    var totalChapters = existing.totalChaptersRead;
    var totalTime = existing.totalReadingTimeMinutes;
    var totalBooksCompleted = existing.totalBooksCompleted;
    var currentStreak = existing.currentStreak;

    if (pagesRead != null && pagesRead > 0) {
      totalPages += pagesRead;
      daily[today] = (daily[today] ?? 0) + pagesRead;
      weekly[week] = (weekly[week] ?? 0) + pagesRead;
      monthly[month] = (monthly[month] ?? 0) + pagesRead;
    }

    if (chaptersRead != null && chaptersRead > 0) {
      totalChapters += chaptersRead;
    }

    if (readingTimeMinutes != null && readingTimeMinutes > 0) {
      totalTime += readingTimeMinutes;
    }

    if (chapterCompleted == true) {
      totalBooksCompleted += 1;
    }

    // simple streak calc
    if (existing.lastReadingDate == null) {
      currentStreak = 1;
    } else {
      final diff = now.difference(existing.lastReadingDate!).inDays;
      if (diff == 0) {
        // same day, keep
      } else if (diff == 1) {
        currentStreak = existing.currentStreak + 1;
      } else {
        currentStreak = 1;
      }
    }

    final updated = existing.copyWith(
      totalPagesRead: totalPages,
      totalChaptersRead: totalChapters,
      totalBooksCompleted: totalBooksCompleted,
      totalReadingTimeMinutes: totalTime,
      currentStreak: currentStreak,
      lastReadingDate: now,
      dailyStats: daily,
      weeklyStats: weekly,
      monthlyStats: monthly,
      updatedAt: now,
    );

    await saveReadingStats(updated);
    return updated;
  }
}
