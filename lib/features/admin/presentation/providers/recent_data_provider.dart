import 'package:flutter_riverpod/flutter_riverpod.dart';
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

