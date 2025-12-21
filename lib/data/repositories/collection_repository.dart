import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firebase_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/collection_model.dart';
import '../../core/utils/logger.dart';

/// Collection repository
class CollectionRepository {
  final FirebaseService _firebaseService = FirebaseService();
  
  FirebaseFirestore get _firestore => _firebaseService.firestore;
  String? get _currentUserId => _firebaseService.currentUserId;
  
  // Get user's collections
  Future<List<CollectionModel>> getUserCollections() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final snapshot = await _firestore
          .collection(AppConstants.collectionsCollection)
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('updatedAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => CollectionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Get user collections error', error: e);
      rethrow;
    }
  }
  
  // Get collection by ID
  Future<CollectionModel?> getCollectionById(String collectionId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionsCollection)
          .doc(collectionId)
          .get();
      
      if (!doc.exists) return null;
      
      return CollectionModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.error('Get collection by ID error', error: e);
      rethrow;
    }
  }
  
  // Create collection
  Future<CollectionModel> createCollection({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final now = DateTime.now();
      final collection = CollectionModel(
        id: '', // Will be set by Firestore
        userId: _currentUserId!,
        name: name,
        description: description,
        isPublic: isPublic,
        createdAt: now,
        updatedAt: now,
      );
      
      final docRef = await _firestore
          .collection(AppConstants.collectionsCollection)
          .add(collection.toFirestore());
      
      return collection.copyWith(id: docRef.id);
    } catch (e) {
      AppLogger.error('Create collection error', error: e);
      rethrow;
    }
  }
  
  // Update collection
  Future<void> updateCollection({
    required String collectionId,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (isPublic != null) updates['isPublic'] = isPublic;
      
      await _firestore
          .collection(AppConstants.collectionsCollection)
          .doc(collectionId)
          .update(updates);
      
      AppLogger.info('Collection updated: $collectionId');
    } catch (e) {
      AppLogger.error('Update collection error', error: e);
      rethrow;
    }
  }
  
  // Delete collection
  Future<void> deleteCollection(String collectionId) async {
    try {
      await _firestore
          .collection(AppConstants.collectionsCollection)
          .doc(collectionId)
          .delete();
      
      AppLogger.info('Collection deleted: $collectionId');
    } catch (e) {
      AppLogger.error('Delete collection error', error: e);
      rethrow;
    }
  }
  
  // Add book to collection
  Future<void> addBookToCollection({
    required String collectionId,
    required String bookId,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.collectionsCollection)
          .doc(collectionId)
          .update({
        'bookIds': FieldValue.arrayUnion([bookId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      AppLogger.info('Book added to collection: $bookId -> $collectionId');
    } catch (e) {
      AppLogger.error('Add book to collection error', error: e);
      rethrow;
    }
  }
  
  // Remove book from collection
  Future<void> removeBookFromCollection({
    required String collectionId,
    required String bookId,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.collectionsCollection)
          .doc(collectionId)
          .update({
        'bookIds': FieldValue.arrayRemove([bookId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      AppLogger.info('Book removed from collection: $bookId <- $collectionId');
    } catch (e) {
      AppLogger.error('Remove book from collection error', error: e);
      rethrow;
    }
  }
  
  // Get collections stream
  Stream<List<CollectionModel>> getUserCollectionsStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(AppConstants.collectionsCollection)
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CollectionModel.fromFirestore(doc))
            .toList());
  }
}

