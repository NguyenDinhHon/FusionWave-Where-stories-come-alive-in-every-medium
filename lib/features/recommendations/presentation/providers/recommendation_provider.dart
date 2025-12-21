import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/recommendation_repository.dart';
import '../../../../data/models/book_model.dart';

/// Recommendation repository provider
final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  return RecommendationRepository();
});

/// Personalized recommendations provider
final personalizedRecommendationsProvider = FutureProvider<List<BookModel>>((ref) async {
  final repository = ref.watch(recommendationRepositoryProvider);
  return repository.getPersonalizedRecommendations();
});

/// Trending books provider
final trendingBooksProvider = FutureProvider<List<BookModel>>((ref) async {
  final repository = ref.watch(recommendationRepositoryProvider);
  return repository.getTrendingBooks();
});

/// Recommendations by category provider
final recommendationsByCategoryProvider = FutureProvider.family<List<BookModel>, String>((ref, category) async {
  final repository = ref.watch(recommendationRepositoryProvider);
  return repository.getRecommendationsByCategory(category);
});

/// Similar books provider
final similarBooksProvider = FutureProvider.family<List<BookModel>, String>((ref, bookId) async {
  final repository = ref.watch(recommendationRepositoryProvider);
  return repository.getSimilarBooks(bookId);
});

/// Recommendation controller provider
final recommendationControllerProvider = Provider<RecommendationController>((ref) {
  return RecommendationController(ref.read(recommendationRepositoryProvider));
});

class RecommendationController {
  final RecommendationRepository _repository;
  
  RecommendationController(this._repository);
  
  Future<List<BookModel>> getPersonalizedRecommendations({int limit = 10}) =>
      _repository.getPersonalizedRecommendations(limit: limit);
  
  Future<List<BookModel>> getTrendingBooks({int limit = 10}) =>
      _repository.getTrendingBooks(limit: limit);
  
  Future<List<BookModel>> getRecommendationsByCategory(String category, {int limit = 10}) =>
      _repository.getRecommendationsByCategory(category, limit: limit);
}

