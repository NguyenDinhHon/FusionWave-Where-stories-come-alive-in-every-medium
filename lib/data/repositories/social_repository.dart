import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firebase_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/comment_model.dart';
import '../models/rating_model.dart';
import '../models/follow_model.dart';
import '../../core/utils/logger.dart';

/// Social repository
class SocialRepository {
  final FirebaseService _firebaseService = FirebaseService();
  
  FirebaseFirestore get _firestore => _firebaseService.firestore;
  String? get _currentUserId => _firebaseService.currentUserId;
  
  // Comments
  
  // Get comments for a book
  Future<List<CommentModel>> getCommentsByBookId(String bookId, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.commentsCollection)
          .where('bookId', isEqualTo: bookId)
          .where('parentCommentId', isNull: true) // Only top-level comments
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Get comments by book ID error', error: e);
      rethrow;
    }
  }
  
  // Get comments by chapter ID
  Future<List<CommentModel>> getCommentsByChapterId(String chapterId, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.commentsCollection)
          .where('chapterId', isEqualTo: chapterId)
          .where('parentCommentId', isNull: true) // Only top-level comments
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Get comments by chapter ID error', error: e);
      rethrow;
    }
  }
  
  // Get replies for a comment
  Future<List<CommentModel>> getCommentReplies(String commentId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.commentsCollection)
          .where('parentCommentId', isEqualTo: commentId)
          .orderBy('createdAt', descending: false)
          .get();
      
      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Get comment replies error', error: e);
      rethrow;
    }
  }
  
  // Add comment
  Future<CommentModel> addComment({
    required String bookId,
    String? chapterId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final comment = CommentModel(
        id: '', // Will be set by Firestore
        userId: _currentUserId!,
        bookId: bookId,
        chapterId: chapterId,
        content: content,
        createdAt: DateTime.now(),
        parentCommentId: parentCommentId,
      );
      
      final docRef = await _firestore
          .collection(AppConstants.commentsCollection)
          .add(comment.toFirestore());
      
      return comment.copyWith(id: docRef.id);
    } catch (e) {
      AppLogger.error('Add comment error', error: e);
      rethrow;
    }
  }
  
  // Like/Unlike comment
  Future<void> toggleCommentLike(String commentId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final commentDoc = await _firestore
          .collection(AppConstants.commentsCollection)
          .doc(commentId)
          .get();
      
      if (!commentDoc.exists) {
        throw Exception('Comment not found');
      }
      
      final comment = CommentModel.fromFirestore(commentDoc);
      final isLiked = comment.likedBy.contains(_currentUserId);
      
      if (isLiked) {
        // Unlike
        await _firestore
            .collection(AppConstants.commentsCollection)
            .doc(commentId)
            .update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([_currentUserId]),
        });
      } else {
        // Like
        await _firestore
            .collection(AppConstants.commentsCollection)
            .doc(commentId)
            .update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([_currentUserId]),
        });
      }
    } catch (e) {
      AppLogger.error('Toggle comment like error', error: e);
      rethrow;
    }
  }
  
  // Delete comment
  Future<void> deleteComment(String commentId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final commentDoc = await _firestore
          .collection(AppConstants.commentsCollection)
          .doc(commentId)
          .get();
      
      final comment = CommentModel.fromFirestore(commentDoc);
      
      if (comment.userId != _currentUserId) {
        throw Exception('Not authorized to delete this comment');
      }
      
      await _firestore
          .collection(AppConstants.commentsCollection)
          .doc(commentId)
          .delete();
      
      AppLogger.info('Comment deleted: $commentId');
    } catch (e) {
      AppLogger.error('Delete comment error', error: e);
      rethrow;
    }
  }
  
  // Ratings
  
  // Get rating for a book by current user
  Future<RatingModel?> getUserRating(String bookId) async {
    try {
      if (_currentUserId == null) return null;
      
      final snapshot = await _firestore
          .collection(AppConstants.ratingsCollection)
          .where('bookId', isEqualTo: bookId)
          .where('userId', isEqualTo: _currentUserId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      return RatingModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      AppLogger.error('Get user rating error', error: e);
      rethrow;
    }
  }
  
  // Get average rating for a book
  Future<double?> getBookAverageRating(String bookId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.ratingsCollection)
          .where('bookId', isEqualTo: bookId)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      final ratings = snapshot.docs
          .map((doc) => RatingModel.fromFirestore(doc))
          .toList();
      
      final sum = ratings.fold<int>(0, (sum, rating) => sum + rating.rating);
      return sum / ratings.length;
    } catch (e) {
      AppLogger.error('Get book average rating error', error: e);
      rethrow;
    }
  }
  
  // Get book reviews (ratings with reviews)
  Future<List<RatingModel>> getBookReviews(String bookId, {int limit = 10}) async {
    try {
      // Avoid composite index by fetching and sorting in memory
      final snapshot = await _firestore
          .collection(AppConstants.ratingsCollection)
          .where('bookId', isEqualTo: bookId)
          .limit(limit * 3) // Get more to filter and sort
          .get();
      
      final reviews = snapshot.docs
          .map((doc) => RatingModel.fromFirestore(doc))
          .where((rating) => rating.review != null && rating.review!.isNotEmpty)
          .toList();
      
      // Sort by createdAt descending
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return reviews.take(limit).toList();
    } catch (e) {
      AppLogger.error('Get book reviews error', error: e);
      return [];
    }
  }
  
  // Add or update rating
  Future<void> rateBook({
    required String bookId,
    required int rating,
    String? review,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      // Check if rating exists
      final existingRating = await getUserRating(bookId);
      
      if (existingRating != null) {
        // Update existing rating
        await _firestore
            .collection(AppConstants.ratingsCollection)
            .doc(existingRating.id)
            .update({
          'rating': rating,
          'review': review,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new rating
        final ratingModel = RatingModel(
          id: '', // Will be set by Firestore
          userId: _currentUserId!,
          bookId: bookId,
          rating: rating,
          review: review,
          createdAt: DateTime.now(),
        );
        
        await _firestore
            .collection(AppConstants.ratingsCollection)
            .add(ratingModel.toFirestore());
      }
      
      // Update book average rating (this would ideally be done via Cloud Function)
      await _updateBookAverageRating(bookId);
      
      AppLogger.info('Book rated: $bookId with $rating stars');
    } catch (e) {
      AppLogger.error('Rate book error', error: e);
      rethrow;
    }
  }
  
  // Update book average rating
  Future<void> _updateBookAverageRating(String bookId) async {
    try {
      final averageRating = await getBookAverageRating(bookId);
      if (averageRating != null) {
        await _firestore
            .collection(AppConstants.booksCollection)
            .doc(bookId)
            .update({
          'averageRating': averageRating,
          'totalRatings': FieldValue.increment(1),
        });
      }
    } catch (e) {
      AppLogger.error('Update book average rating error', error: e);
    }
  }
  
  // Follow/Unfollow
  
  // Follow user
  Future<void> followUser(String userId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      if (_currentUserId == userId) {
        throw Exception('Cannot follow yourself');
      }
      
      // Check if already following
      final isFollowing = await isFollowingUser(userId);
      if (isFollowing) {
        throw Exception('Already following this user');
      }
      
      final follow = FollowModel(
        id: '', // Will be set by Firestore
        followerId: _currentUserId!,
        followingId: userId,
        createdAt: DateTime.now(),
      );
      
      await _firestore
          .collection(AppConstants.followsCollection)
          .add(follow.toFirestore());
      
      AppLogger.info('User followed: $userId');
    } catch (e) {
      AppLogger.error('Follow user error', error: e);
      rethrow;
    }
  }
  
  // Unfollow user
  Future<void> unfollowUser(String userId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final snapshot = await _firestore
          .collection(AppConstants.followsCollection)
          .where('followerId', isEqualTo: _currentUserId)
          .where('followingId', isEqualTo: userId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) {
        throw Exception('Not following this user');
      }
      
      await _firestore
          .collection(AppConstants.followsCollection)
          .doc(snapshot.docs.first.id)
          .delete();
      
      AppLogger.info('User unfollowed: $userId');
    } catch (e) {
      AppLogger.error('Unfollow user error', error: e);
      rethrow;
    }
  }
  
  // Check if following user
  Future<bool> isFollowingUser(String userId) async {
    try {
      if (_currentUserId == null) return false;
      
      final snapshot = await _firestore
          .collection(AppConstants.followsCollection)
          .where('followerId', isEqualTo: _currentUserId)
          .where('followingId', isEqualTo: userId)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      AppLogger.error('Check following user error', error: e);
      return false;
    }
  }
  
  // Get followers count
  Future<int> getFollowersCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.followsCollection)
          .where('followingId', isEqualTo: userId)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      AppLogger.error('Get followers count error', error: e);
      return 0;
    }
  }
  
  // Get following count
  Future<int> getFollowingCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.followsCollection)
          .where('followerId', isEqualTo: userId)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      AppLogger.error('Get following count error', error: e);
      return 0;
    }
  }
  
  // Chapter Likes
  
  // Like/Unlike chapter
  Future<void> toggleChapterLike(String chapterId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      // Check if already liked
      final snapshot = await _firestore
          .collection(AppConstants.chapterLikesCollection)
          .where('userId', isEqualTo: _currentUserId)
          .where('chapterId', isEqualTo: chapterId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        // Unlike - delete the like document
        await _firestore
            .collection(AppConstants.chapterLikesCollection)
            .doc(snapshot.docs.first.id)
            .delete();
        
        // Decrement like count in chapter
        await _firestore
            .collection(AppConstants.chaptersCollection)
            .doc(chapterId)
            .update({
          'likes': FieldValue.increment(-1),
        });
      } else {
        // Like - create new like document
        await _firestore
            .collection(AppConstants.chapterLikesCollection)
            .add({
          'userId': _currentUserId,
          'chapterId': chapterId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Increment like count in chapter
        await _firestore
            .collection(AppConstants.chaptersCollection)
            .doc(chapterId)
            .update({
          'likes': FieldValue.increment(1),
        });
      }
      
      AppLogger.info('Chapter like toggled: $chapterId');
    } catch (e) {
      AppLogger.error('Toggle chapter like error', error: e);
      rethrow;
    }
  }
  
  // Check if chapter is liked by current user
  Future<bool> isChapterLiked(String chapterId) async {
    try {
      if (_currentUserId == null) return false;
      
      final snapshot = await _firestore
          .collection(AppConstants.chapterLikesCollection)
          .where('userId', isEqualTo: _currentUserId)
          .where('chapterId', isEqualTo: chapterId)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      AppLogger.error('Check chapter like error', error: e);
      return false;
    }
  }
  
  // Get chapter like count
  Future<int> getChapterLikeCount(String chapterId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.chapterLikesCollection)
          .where('chapterId', isEqualTo: chapterId)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      AppLogger.error('Get chapter like count error', error: e);
      // Fallback: get from chapter document
      try {
        final chapterDoc = await _firestore
            .collection(AppConstants.chaptersCollection)
            .doc(chapterId)
            .get();
        
        return (chapterDoc.data()?['likes'] as int?) ?? 0;
      } catch (e2) {
        return 0;
      }
    }
  }
  
  // Leaderboard
  
  // Get top readers
  Future<List<Map<String, dynamic>>> getTopReaders({int limit = 10}) async {
    try {
      // Get users sorted by reading stats
      final statsSnapshot = await _firestore
          .collection(AppConstants.readingStatsCollection)
          .orderBy('totalPagesRead', descending: true)
          .limit(limit)
          .get();
      
      final topReaders = <Map<String, dynamic>>[];
      
      for (var doc in statsSnapshot.docs) {
        final userId = doc.id;
        final stats = doc.data();
        
        // Get user info
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .get();
        
        if (userDoc.exists) {
          topReaders.add({
            'userId': userId,
            'displayName': userDoc.data()?['displayName'] ?? 'Unknown',
            'photoUrl': userDoc.data()?['photoUrl'],
            'totalPagesRead': stats['totalPagesRead'] ?? 0,
            'currentStreak': stats['currentStreak'] ?? 0,
          });
        }
      }
      
      return topReaders;
    } catch (e) {
      AppLogger.error('Get top readers error', error: e);
      rethrow;
    }
  }
}

