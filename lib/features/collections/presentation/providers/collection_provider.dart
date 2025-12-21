import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/collection_repository.dart';
import '../../../../data/models/collection_model.dart';

/// Collection repository provider
final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return CollectionRepository();
});

/// User collections provider
final userCollectionsProvider = StreamProvider<List<CollectionModel>>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return repository.getUserCollectionsStream();
});

/// Collection by ID provider
final collectionByIdProvider = FutureProvider.family<CollectionModel?, String>((ref, collectionId) async {
  final repository = ref.watch(collectionRepositoryProvider);
  return repository.getCollectionById(collectionId);
});

/// Collection controller provider
final collectionControllerProvider = Provider<CollectionController>((ref) {
  return CollectionController(ref.read(collectionRepositoryProvider));
});

class CollectionController {
  final CollectionRepository _repository;
  
  CollectionController(this._repository);
  
  Future<CollectionModel> createCollection({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    return _repository.createCollection(
      name: name,
      description: description,
      isPublic: isPublic,
    );
  }
  
  Future<void> updateCollection({
    required String collectionId,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    await _repository.updateCollection(
      collectionId: collectionId,
      name: name,
      description: description,
      isPublic: isPublic,
    );
  }
  
  Future<void> deleteCollection(String collectionId) async {
    await _repository.deleteCollection(collectionId);
  }
  
  Future<void> addBookToCollection({
    required String collectionId,
    required String bookId,
  }) async {
    await _repository.addBookToCollection(
      collectionId: collectionId,
      bookId: bookId,
    );
  }
  
  Future<void> removeBookFromCollection({
    required String collectionId,
    required String bookId,
  }) async {
    await _repository.removeBookFromCollection(
      collectionId: collectionId,
      bookId: bookId,
    );
  }
}

