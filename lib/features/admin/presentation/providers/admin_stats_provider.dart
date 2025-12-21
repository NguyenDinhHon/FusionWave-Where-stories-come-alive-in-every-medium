import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Admin statistics model
class AdminStats {
  final int totalBooks;
  final int totalUsers;
  final int totalViews;
  final int totalChapters;
  final int publishedBooks;
  final int draftBooks;

  AdminStats({
    required this.totalBooks,
    required this.totalUsers,
    required this.totalViews,
    required this.totalChapters,
    required this.publishedBooks,
    required this.draftBooks,
  });
}

/// Provider for admin statistics
final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final firestore = FirebaseService().firestore;

  // Get all stats in parallel
  final results = await Future.wait([
    // Total books
    firestore.collection(AppConstants.booksCollection).count().get(),
    // Total users
    firestore.collection(AppConstants.usersCollection).count().get(),
    // Total chapters
    firestore.collection(AppConstants.chaptersCollection).count().get(),
    // Published books
    firestore
        .collection(AppConstants.booksCollection)
        .where('isPublished', isEqualTo: true)
        .count()
        .get(),
    // Draft books
    firestore
        .collection(AppConstants.booksCollection)
        .where('isPublished', isEqualTo: false)
        .count()
        .get(),
  ]);

  // Calculate total views (sum of totalReads from all books)
  final booksSnapshot = await firestore
      .collection(AppConstants.booksCollection)
      .get();
  
  int totalViews = 0;
  for (var doc in booksSnapshot.docs) {
    final data = doc.data();
    totalViews += data['totalReads'] as int? ?? 0;
  }

  return AdminStats(
    totalBooks: results[0].count ?? 0,
    totalUsers: results[1].count ?? 0,
    totalViews: totalViews,
    totalChapters: results[2].count ?? 0,
    publishedBooks: results[3].count ?? 0,
    draftBooks: results[4].count ?? 0,
  );
});

