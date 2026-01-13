import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/book_model.dart';
import '../../../home/presentation/providers/book_provider.dart';

/// Provider for recent books (admin)
final recentBooksProvider = FutureProvider<List<BookModel>>((ref) async {
  final repository = ref.read(bookRepositoryProvider);
  return repository.getAllBooks(limit: 5);
});

/// Provider for recent users
final recentUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final firestore = FirebaseService().firestore;
  final snapshot = await firestore
      .collection(AppConstants.usersCollection)
      .orderBy('createdAt', descending: true)
      .limit(5)
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    return {
      'id': doc.id,
      'email': data['email'] ?? '',
      'displayName': data['displayName'] ?? 'Unknown',
      'role': data['role'] ?? AppConstants.roleUser,
      'createdAt': data['createdAt'],
      'photoUrl': data['photoUrl'],
    };
  }).toList();
});

/// Provider for recent comments count (last 24 hours)
final recentCommentsCountProvider = FutureProvider<int>((ref) async {
  final firestore = FirebaseService().firestore;
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  
  try {
    final snapshot = await firestore
        .collection(AppConstants.commentsCollection)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(yesterday))
        .count()
        .get();
    
    return snapshot.count ?? 0;
  } catch (e) {
    // If query fails, get all and filter in memory
    final snapshot = await firestore
        .collection(AppConstants.commentsCollection)
        .get();
    
    return snapshot.docs.where((doc) {
      final data = doc.data();
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      return createdAt != null && createdAt.isAfter(yesterday);
    }).length;
  }
});

/// Provider for recent ratings count (last 24 hours)
final recentRatingsCountProvider = FutureProvider<int>((ref) async {
  final firestore = FirebaseService().firestore;
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  
  try {
    final snapshot = await firestore
        .collection(AppConstants.ratingsCollection)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(yesterday))
        .count()
        .get();
    
    return snapshot.count ?? 0;
  } catch (e) {
    // If query fails, get all and filter in memory
    final snapshot = await firestore
        .collection(AppConstants.ratingsCollection)
        .get();
    
    return snapshot.docs.where((doc) {
      final data = doc.data();
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      return createdAt != null && createdAt.isAfter(yesterday);
    }).length;
  }
});

/// Provider for recent bookmarks count (last 24 hours)
final recentBookmarksCountProvider = FutureProvider<int>((ref) async {
  final firestore = FirebaseService().firestore;
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  
  try {
    final snapshot = await firestore
        .collection(AppConstants.bookmarksCollection)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(yesterday))
        .count()
        .get();
    
    return snapshot.count ?? 0;
  } catch (e) {
    // If query fails, get all and filter in memory
    final snapshot = await firestore
        .collection(AppConstants.bookmarksCollection)
        .get();
    
    return snapshot.docs.where((doc) {
      final data = doc.data();
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      return createdAt != null && createdAt.isAfter(yesterday);
    }).length;
  }
});
