import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Time period enum
enum TimePeriod {
  last7Days,
  last30Days,
  last90Days,
  allTime,
}

extension TimePeriodExtension on TimePeriod {
  int get days {
    switch (this) {
      case TimePeriod.last7Days:
        return 7;
      case TimePeriod.last30Days:
        return 30;
      case TimePeriod.last90Days:
        return 90;
      case TimePeriod.allTime:
        return -1; // All time
    }
  }

  String get label {
    switch (this) {
      case TimePeriod.last7Days:
        return '7 Ngày';
      case TimePeriod.last30Days:
        return '30 Ngày';
      case TimePeriod.last90Days:
        return '90 Ngày';
      case TimePeriod.allTime:
        return 'Tất Cả';
    }
  }
}

/// Time series data point
class TimeSeriesData {
  final DateTime date;
  final int books;
  final int users;
  final int views;
  final int comments;
  final int ratings;

  TimeSeriesData({
    required this.date,
    required this.books,
    required this.users,
    required this.views,
    required this.comments,
    required this.ratings,
  });
}

/// Category distribution
class CategoryDistribution {
  final String category;
  final int count;

  CategoryDistribution({
    required this.category,
    required this.count,
  });
}

/// Book status distribution
class BookStatusDistribution {
  final int published;
  final int draft;

  BookStatusDistribution({
    required this.published,
    required this.draft,
  });
}

/// User activity stats
class UserActivityStats {
  final int activeLast7Days;
  final int activeLast30Days;
  final int totalActive;

  UserActivityStats({
    required this.activeLast7Days,
    required this.activeLast30Days,
    required this.totalActive,
  });
}

/// Provider for time series stats with configurable period
final timeSeriesStatsProvider = FutureProvider.family<List<TimeSeriesData>, TimePeriod>((ref, period) async {
  final firestore = FirebaseService().firestore;
  final now = DateTime.now();
  final days = period.days;
  final startDate = days == -1 ? null : now.subtract(Duration(days: days));

  // Get books
  final booksQuery = firestore.collection(AppConstants.booksCollection);
  final booksSnapshot = startDate != null
      ? await booksQuery.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate)).get()
      : await booksQuery.get();

  // Get users
  final usersQuery = firestore.collection(AppConstants.usersCollection);
  final usersSnapshot = startDate != null
      ? await usersQuery.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate)).get()
      : await usersQuery.get();

  // Get comments
  final commentsQuery = firestore.collection(AppConstants.commentsCollection);
  final commentsSnapshot = startDate != null
      ? await commentsQuery.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate)).get()
      : await commentsQuery.get();

  // Get ratings
  final ratingsQuery = firestore.collection(AppConstants.ratingsCollection);
  final ratingsSnapshot = startDate != null
      ? await ratingsQuery.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate)).get()
      : await ratingsQuery.get();

  // Group by date
  final Map<String, TimeSeriesData> dataMap = {};
  
  // Initialize date range
  final numDays = days == -1 ? 365 : days; // For all time, show last 365 days
  for (int i = 0; i < numDays; i++) {
    final date = now.subtract(Duration(days: numDays - 1 - i));
    final dateKey = DateTime(date.year, date.month, date.day);
    dataMap[dateKey.toString()] = TimeSeriesData(
      date: dateKey,
      books: 0,
      users: 0,
      views: 0,
      comments: 0,
      ratings: 0,
    );
  }

  // Process books
  for (var doc in booksSnapshot.docs) {
    final data = doc.data();
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    if (createdAt != null) {
      final dateKey = DateTime(createdAt.year, createdAt.month, createdAt.day);
      final key = dateKey.toString();
      if (dataMap.containsKey(key)) {
        final existing = dataMap[key]!;
        dataMap[key] = TimeSeriesData(
          date: existing.date,
          books: existing.books + 1,
          users: existing.users,
          views: existing.views,
          comments: existing.comments,
          ratings: existing.ratings,
        );
      }
    }
  }

  // Process users
  for (var doc in usersSnapshot.docs) {
    final data = doc.data();
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    if (createdAt != null) {
      final dateKey = DateTime(createdAt.year, createdAt.month, createdAt.day);
      final key = dateKey.toString();
      if (dataMap.containsKey(key)) {
        final existing = dataMap[key]!;
        dataMap[key] = TimeSeriesData(
          date: existing.date,
          books: existing.books,
          users: existing.users + 1,
          views: existing.views,
          comments: existing.comments,
          ratings: existing.ratings,
        );
      }
    }
  }

  // Process comments
  for (var doc in commentsSnapshot.docs) {
    final data = doc.data();
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    if (createdAt != null) {
      final dateKey = DateTime(createdAt.year, createdAt.month, createdAt.day);
      final key = dateKey.toString();
      if (dataMap.containsKey(key)) {
        final existing = dataMap[key]!;
        dataMap[key] = TimeSeriesData(
          date: existing.date,
          books: existing.books,
          users: existing.users,
          views: existing.views,
          comments: existing.comments + 1,
          ratings: existing.ratings,
        );
      }
    }
  }

  // Process ratings
  for (var doc in ratingsSnapshot.docs) {
    final data = doc.data();
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    if (createdAt != null) {
      final dateKey = DateTime(createdAt.year, createdAt.month, createdAt.day);
      final key = dateKey.toString();
      if (dataMap.containsKey(key)) {
        final existing = dataMap[key]!;
        dataMap[key] = TimeSeriesData(
          date: existing.date,
          books: existing.books,
          users: existing.users,
          views: existing.views,
          comments: existing.comments,
          ratings: existing.ratings + 1,
        );
      }
    }
  }

  // Get views (totalReads from books) - approximate by checking book updates
  final allBooksSnapshot = await firestore
      .collection(AppConstants.booksCollection)
      .get();
  
  for (var doc in allBooksSnapshot.docs) {
    final data = doc.data();
    final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
    final totalReads = data['totalReads'] as int? ?? 0;
    if (updatedAt != null && totalReads > 0) {
      final dateKey = DateTime(updatedAt.year, updatedAt.month, updatedAt.day);
      final key = dateKey.toString();
      if (dataMap.containsKey(key)) {
        final existing = dataMap[key]!;
        // Distribute views proportionally (simplified)
        dataMap[key] = TimeSeriesData(
          date: existing.date,
          books: existing.books,
          users: existing.users,
          views: existing.views + (totalReads ~/ 30), // Approximate
          comments: existing.comments,
          ratings: existing.ratings,
        );
      }
    }
  }

  return dataMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));
});

/// Provider for daily stats (last 30 days) - kept for backward compatibility
final dailyStatsProvider = FutureProvider<List<TimeSeriesData>>((ref) async {
  return await ref.read(timeSeriesStatsProvider(TimePeriod.last30Days).future);
});

/// Provider for category distribution
final categoryDistributionProvider = FutureProvider<List<CategoryDistribution>>((ref) async {
  final firestore = FirebaseService().firestore;
  final booksSnapshot = await firestore
      .collection(AppConstants.booksCollection)
      .get();

  final Map<String, int> categoryCount = {};
  
  for (var doc in booksSnapshot.docs) {
    final data = doc.data();
    final category = data['category'] as String? ?? 'Unknown';
    categoryCount[category] = (categoryCount[category] ?? 0) + 1;
  }

  return categoryCount.entries
      .map((e) => CategoryDistribution(category: e.key, count: e.value))
      .toList()
    ..sort((a, b) => b.count.compareTo(a.count));
});

/// Provider for book status distribution
final bookStatusDistributionProvider = FutureProvider<BookStatusDistribution>((ref) async {
  final firestore = FirebaseService().firestore;
  
  final publishedCount = await firestore
      .collection(AppConstants.booksCollection)
      .where('isPublished', isEqualTo: true)
      .count()
      .get();
  
  final draftCount = await firestore
      .collection(AppConstants.booksCollection)
      .where('isPublished', isEqualTo: false)
      .count()
      .get();

  return BookStatusDistribution(
    published: publishedCount.count ?? 0,
    draft: draftCount.count ?? 0,
  );
});

/// Provider for user activity stats
final userActivityStatsProvider = FutureProvider<UserActivityStats>((ref) async {
  final firestore = FirebaseService().firestore;
  final now = DateTime.now();
  final sevenDaysAgo = now.subtract(const Duration(days: 7));
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));

  // Users active in last 7 days (users with lastLogin in last 7 days)
  final active7DaysSnapshot = await firestore
      .collection(AppConstants.usersCollection)
      .where('lastLogin', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
      .count()
      .get();

  // Users active in last 30 days
  final active30DaysSnapshot = await firestore
      .collection(AppConstants.usersCollection)
      .where('lastLogin', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
      .count()
      .get();

  // Total active users (users with lastLogin in last 90 days)
  final ninetyDaysAgo = now.subtract(const Duration(days: 90));
  final totalActiveSnapshot = await firestore
      .collection(AppConstants.usersCollection)
      .where('lastLogin', isGreaterThanOrEqualTo: Timestamp.fromDate(ninetyDaysAgo))
      .count()
      .get();

  return UserActivityStats(
    activeLast7Days: active7DaysSnapshot.count ?? 0,
    activeLast30Days: active30DaysSnapshot.count ?? 0,
    totalActive: totalActiveSnapshot.count ?? 0,
  );
});

/// Provider for top books by views
final topBooksByViewsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final firestore = FirebaseService().firestore;
  final booksSnapshot = await firestore
      .collection(AppConstants.booksCollection)
      .orderBy('totalReads', descending: true)
      .limit(10)
      .get();

  return booksSnapshot.docs.map((doc) {
    final data = doc.data();
    return {
      'id': doc.id,
      'title': data['title'] ?? 'Unknown',
      'views': data['totalReads'] ?? 0,
      'rating': data['averageRating'] ?? 0.0,
    };
  }).toList();
});

/// Provider for top books by rating
final topBooksByRatingProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final firestore = FirebaseService().firestore;
  final booksSnapshot = await firestore
      .collection(AppConstants.booksCollection)
      .where('averageRating', isGreaterThan: 0)
      .orderBy('averageRating', descending: true)
      .limit(10)
      .get();

  return booksSnapshot.docs.map((doc) {
    final data = doc.data();
    return {
      'id': doc.id,
      'title': data['title'] ?? 'Unknown',
      'rating': data['averageRating'] ?? 0.0,
      'totalRatings': data['totalRatings'] ?? 0,
    };
  }).toList();
});
