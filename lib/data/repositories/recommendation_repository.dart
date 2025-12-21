import '../../core/services/firebase_service.dart';
import '../models/book_model.dart';
import '../repositories/book_repository.dart';
import '../repositories/library_repository.dart';
import '../../core/utils/logger.dart';

/// Recommendation repository
class RecommendationRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final BookRepository _bookRepository = BookRepository();
  final LibraryRepository _libraryRepository = LibraryRepository();
  
  String? get _currentUserId => _firebaseService.currentUserId;
  
  // Get personalized recommendations
  Future<List<BookModel>> getPersonalizedRecommendations({int limit = 10}) async {
    try {
      if (_currentUserId == null) {
        // Return featured books if not logged in
        return _bookRepository.getFeaturedBooks(limit: limit);
      }
      
      // Get user's reading history
      final libraryItems = await _libraryRepository.getLibraryItems();
      
      // Get user's favorite categories
      final favoriteCategories = _getFavoriteCategories(libraryItems);
      
      // Get books by favorite categories
      final recommendedBooks = <BookModel>[];
      
      for (var category in favoriteCategories.take(3)) {
        final books = await _bookRepository.getBooksByCategory(category, limit: 5);
        recommendedBooks.addAll(books);
      }
      
      // Remove books already in library
      final libraryBookIds = libraryItems.map((item) => item.bookId).toSet();
      recommendedBooks.removeWhere((book) => libraryBookIds.contains(book.id));
      
      // Sort by rating and popularity
      recommendedBooks.sort((a, b) {
        final ratingA = a.averageRating ?? 0;
        final ratingB = b.averageRating ?? 0;
        if (ratingA != ratingB) {
          return ratingB.compareTo(ratingA);
        }
        return b.totalReads.compareTo(a.totalReads);
      });
      
      return recommendedBooks.take(limit).toList();
    } catch (e) {
      AppLogger.error('Get personalized recommendations error', error: e);
      // Fallback to featured books
      return _bookRepository.getFeaturedBooks(limit: limit);
    }
  }
  
  // Get favorite categories from reading history
  List<String> _getFavoriteCategories(List<dynamic> libraryItems) {
    // TODO: Get categories from books in library
    // For now, return default categories
    return ['Fiction', 'Non-Fiction', 'Science'];
  }
  
  // Get recommendations based on similar users
  Future<List<BookModel>> getSimilarUsersRecommendations({int limit = 10}) async {
    try {
      // TODO: Implement collaborative filtering
      // For now, return featured books
      return _bookRepository.getFeaturedBooks(limit: limit);
    } catch (e) {
      AppLogger.error('Get similar users recommendations error', error: e);
      return [];
    }
  }
  
  // Get trending books
  Future<List<BookModel>> getTrendingBooks({int limit = 10}) async {
    try {
      return _bookRepository.getFeaturedBooks(limit: limit);
    } catch (e) {
      AppLogger.error('Get trending books error', error: e);
      return [];
    }
  }
  
  // Get recommendations by category
  Future<List<BookModel>> getRecommendationsByCategory(String category, {int limit = 10}) async {
    try {
      return _bookRepository.getBooksByCategory(category, limit: limit);
    } catch (e) {
      AppLogger.error('Get recommendations by category error', error: e);
      return [];
    }
  }
  
  // Get similar books based on a book
  Future<List<BookModel>> getSimilarBooks(String bookId, {int limit = 10}) async {
    try {
      if (bookId.isEmpty) {
        return [];
      }
      
      // Get the book to find similar ones
      final book = await _bookRepository.getBookById(bookId);
      if (book == null) {
        return [];
      }
      
      // Find books with similar categories
      final similarBooks = <BookModel>[];
      
      for (var category in book.categories.take(2)) {
        final books = await _bookRepository.getBooksByCategory(category, limit: limit * 2);
        similarBooks.addAll(books.where((b) => b.id != bookId));
      }
      
      // Remove duplicates and sort by rating
      final uniqueBooks = <String, BookModel>{};
      for (var book in similarBooks) {
        if (!uniqueBooks.containsKey(book.id)) {
          uniqueBooks[book.id] = book;
        }
      }
      
      final result = uniqueBooks.values.toList();
      result.sort((a, b) {
        final ratingA = a.averageRating ?? 0;
        final ratingB = b.averageRating ?? 0;
        if (ratingA != ratingB) {
          return ratingB.compareTo(ratingA);
        }
        return b.totalReads.compareTo(a.totalReads);
      });
      
      return result.take(limit).toList();
    } catch (e) {
      AppLogger.error('Get similar books error', error: e);
      return [];
    }
  }
}

