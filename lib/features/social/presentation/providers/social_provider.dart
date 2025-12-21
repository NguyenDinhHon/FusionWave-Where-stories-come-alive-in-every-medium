import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/social_repository.dart';
import '../../../../data/models/comment_model.dart';
import '../../../../data/models/rating_model.dart';

/// Social repository provider
final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepository();
});

/// Comments by book ID provider
final commentsByBookIdProvider = FutureProvider.family<List<CommentModel>, String>((ref, bookId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getCommentsByBookId(bookId);
});

/// User rating provider
final userRatingProvider = FutureProvider.family<RatingModel?, String>((ref, bookId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getUserRating(bookId);
});

/// Book average rating provider
final bookAverageRatingProvider = FutureProvider.family<double?, String>((ref, bookId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getBookAverageRating(bookId);
});

/// Book reviews provider (ratings with reviews)
final bookReviewsProvider = FutureProvider.family<List<RatingModel>, String>((ref, bookId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getBookReviews(bookId);
});

/// Is following user provider
final isFollowingUserProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.isFollowingUser(userId);
});

/// Top readers provider
final topReadersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getTopReaders();
});

/// Social controller provider
final socialControllerProvider = Provider<SocialController>((ref) {
  return SocialController(ref.read(socialRepositoryProvider));
});

class SocialController {
  final SocialRepository _repository;
  
  SocialController(this._repository);
  
  Future<CommentModel> addComment({
    required String bookId,
    String? chapterId,
    required String content,
    String? parentCommentId,
  }) => _repository.addComment(
    bookId: bookId,
    chapterId: chapterId,
    content: content,
    parentCommentId: parentCommentId,
  );
  
  Future<void> toggleCommentLike(String commentId) => 
      _repository.toggleCommentLike(commentId);
  
  Future<void> deleteComment(String commentId) => 
      _repository.deleteComment(commentId);
  
  Future<void> rateBook({
    required String bookId,
    required int rating,
    String? review,
  }) => _repository.rateBook(
    bookId: bookId,
    rating: rating,
    review: review,
  );
  
  Future<void> followUser(String userId) => _repository.followUser(userId);
  Future<void> unfollowUser(String userId) => _repository.unfollowUser(userId);
  Future<bool> isFollowingUser(String userId) => _repository.isFollowingUser(userId);
  Future<int> getFollowersCount(String userId) => _repository.getFollowersCount(userId);
  Future<int> getFollowingCount(String userId) => _repository.getFollowingCount(userId);
  
  // Chapter likes
  Future<void> toggleChapterLike(String chapterId) => _repository.toggleChapterLike(chapterId);
  Future<bool> isChapterLiked(String chapterId) => _repository.isChapterLiked(chapterId);
  Future<int> getChapterLikeCount(String chapterId) => _repository.getChapterLikeCount(chapterId);
}

