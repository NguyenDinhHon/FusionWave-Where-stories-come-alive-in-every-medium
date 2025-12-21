import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firebase_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/book_model.dart';
import '../../core/utils/logger.dart';

/// Book repository
class BookRepository {
  final FirebaseService _firebaseService = FirebaseService();
  
  FirebaseFirestore get _firestore => _firebaseService.firestore;
  
  // Get all books with pagination
  Future<List<BookModel>> getBooks({
    int limit = AppConstants.booksPerPage,
    DocumentSnapshot? startAfter,
    String? category,
    String? searchQuery,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.booksCollection)
          .where('isPublished', isEqualTo: true);
      
      // If category is provided, add it but don't use orderBy to avoid index requirement
      if (category != null && category.isNotEmpty) {
        query = query.where('categories', arrayContains: category);
        // Get more to sort in memory
        query = query.limit(limit * 2);
      } else {
        // Only use orderBy when no category filter
        query = query.orderBy('createdAt', descending: true).limit(limit);
      }
      
      if (startAfter != null && category == null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      
      List<BookModel> books = snapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .toList();
      
      // Sort in memory if category filter was used
      if (category != null && category.isNotEmpty) {
        books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        books = books.take(limit).toList();
      }
      
      // Filter by search query if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final queryLower = searchQuery.toLowerCase();
        books = books.where((book) {
          return book.title.toLowerCase().contains(queryLower) ||
              book.authors.any((author) => author.toLowerCase().contains(queryLower)) ||
              book.categories.any((cat) => cat.toLowerCase().contains(queryLower));
        }).toList();
      }
      
      return books;
    } catch (e) {
      AppLogger.error('Get books error', error: e);
      rethrow;
    }
  }
  
  // Get featured books
  Future<List<BookModel>> getFeaturedBooks({int limit = 10}) async {
    try {
      // Get all published books and sort in memory to avoid index requirement
      final snapshot = await _firestore
          .collection(AppConstants.booksCollection)
          .where('isPublished', isEqualTo: true)
          .limit(50) // Get more to sort
          .get();
      
      final books = snapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .toList();
      
      // Sort by totalReads descending
      books.sort((a, b) => b.totalReads.compareTo(a.totalReads));
      
      // Return top books
      return books.take(limit).toList();
    } catch (e) {
      AppLogger.error('Get featured books error', error: e);
      rethrow;
    }
  }
  
  // Get book by ID
  Future<BookModel?> getBookById(String bookId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .get();
      
      if (!doc.exists) return null;
      
      return BookModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.error('Get book by ID error', error: e);
      rethrow;
    }
  }
  
  // Get books by category
  Future<List<BookModel>> getBooksByCategory(String category, {int limit = 20}) async {
    try {
      // Use arrayContains which doesn't require index with orderBy
      final snapshot = await _firestore
          .collection(AppConstants.booksCollection)
          .where('isPublished', isEqualTo: true)
          .where('categories', arrayContains: category)
          .limit(limit * 2) // Get more to sort
          .get();
      
      final books = snapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .toList();
      
      // Sort by createdAt descending
      books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return books.take(limit).toList();
    } catch (e) {
      AppLogger.error('Get books by category error', error: e);
      rethrow;
    }
  }
  
  // Search books
  Future<List<BookModel>> searchBooks(String query, {int limit = 20}) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple implementation. For production, consider using Algolia or similar
      // Get all published books (without orderBy to avoid index requirement)
      final snapshot = await _firestore
          .collection(AppConstants.booksCollection)
          .where('isPublished', isEqualTo: true)
          .limit(100) // Get more to filter in memory
          .get();
      
      final queryLower = query.toLowerCase().trim();
      if (queryLower.isEmpty) {
        return [];
      }
      
      final books = snapshot.docs
          .map((doc) {
            try {
              return BookModel.fromFirestore(doc);
            } catch (e) {
              AppLogger.error('Error parsing book document ${doc.id}', error: e);
              return null;
            }
          })
          .where((book) => book != null)
          .cast<BookModel>()
          .where((book) {
            return book.title.toLowerCase().contains(queryLower) ||
                book.authors.any((author) => author.toLowerCase().contains(queryLower)) ||
                book.categories.any((cat) => cat.toLowerCase().contains(queryLower)) ||
                (book.description?.toLowerCase().contains(queryLower) ?? false);
          })
          .take(limit)
          .toList();
      
      // Sort by relevance (title matches first, then authors, then categories)
      books.sort((a, b) {
        final aTitleMatch = a.title.toLowerCase().contains(queryLower);
        final bTitleMatch = b.title.toLowerCase().contains(queryLower);
        if (aTitleMatch && !bTitleMatch) return -1;
        if (!aTitleMatch && bTitleMatch) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
      
      return books;
    } catch (e) {
      AppLogger.error('Search books error', error: e);
      rethrow;
    }
  }
  
  // Get new releases (books published in last 30 days)
  Future<List<BookModel>> getNewReleases({int limit = 10}) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final snapshot = await _firestore
          .collection(AppConstants.booksCollection)
          .where('isPublished', isEqualTo: true)
          .limit(50)
          .get();
      
      final books = snapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .where((book) => book.createdAt.isAfter(thirtyDaysAgo))
          .toList();
      
      // Sort by createdAt descending
      books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return books.take(limit).toList();
    } catch (e) {
      AppLogger.error('Get new releases error', error: e);
      return [];
    }
  }
  
  // Get hot books this week (books with most reads in last 7 days)
  Future<List<BookModel>> getHotThisWeek({int limit = 10}) async {
    try {
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      final snapshot = await _firestore
          .collection(AppConstants.booksCollection)
          .where('isPublished', isEqualTo: true)
          .limit(50)
          .get();
      
      final books = snapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .where((book) => book.createdAt.isAfter(oneWeekAgo) || book.updatedAt.isAfter(oneWeekAgo))
          .toList();
      
      // Sort by totalReads descending
      books.sort((a, b) => b.totalReads.compareTo(a.totalReads));
      
      return books.take(limit).toList();
    } catch (e) {
      AppLogger.error('Get hot this week error', error: e);
      return [];
    }
  }
  
  // Get rising stars (books with high rating and recent activity)
  Future<List<BookModel>> getRisingStars({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.booksCollection)
          .where('isPublished', isEqualTo: true)
          .limit(50)
          .get();
      
      final books = snapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .where((book) => (book.averageRating ?? 0) >= 4.0)
          .toList();
      
      // Sort by rating and recent activity
      books.sort((a, b) {
        final ratingA = a.averageRating ?? 0;
        final ratingB = b.averageRating ?? 0;
        if (ratingA != ratingB) {
          return ratingB.compareTo(ratingA);
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });
      
      return books.take(limit).toList();
    } catch (e) {
      AppLogger.error('Get rising stars error', error: e);
      return [];
    }
  }
  
  // Get editor's picks (highly rated books with good reviews)
  Future<List<BookModel>> getEditorsPicks({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.booksCollection)
          .where('isPublished', isEqualTo: true)
          .limit(50)
          .get();
      
      final books = snapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .where((book) => (book.averageRating ?? 0) >= 4.5 && book.totalReads > 100)
          .toList();
      
      // Sort by rating and reads
      books.sort((a, b) {
        final ratingA = a.averageRating ?? 0;
        final ratingB = b.averageRating ?? 0;
        if (ratingA != ratingB) {
          return ratingB.compareTo(ratingA);
        }
        return b.totalReads.compareTo(a.totalReads);
      });
      
      return books.take(limit).toList();
    } catch (e) {
      AppLogger.error('Get editor\'s picks error', error: e);
      return [];
    }
  }
  
  // Get recommended books (simple implementation)
  Future<List<BookModel>> getRecommendedBooks(String userId, {int limit = 10}) async {
    try {
      // TODO: Implement AI-based recommendations
      // For now, return popular books
      return getFeaturedBooks(limit: limit);
    } catch (e) {
      AppLogger.error('Get recommended books error', error: e);
      rethrow;
    }
  }
  
  // Increment book reads
  Future<void> incrementBookReads(String bookId) async {
    try {
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .update({
        'totalReads': FieldValue.increment(1),
      });
    } catch (e) {
      AppLogger.error('Increment book reads error', error: e);
    }
  }

  // Create book
  Future<BookModel> createBook(BookModel book) async {
    try {
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(book.id)
          .set(book.toFirestore());
      return book;
    } catch (e) {
      AppLogger.error('Create book error', error: e);
      rethrow;
    }
  }

  // Update book
  Future<void> updateBook(BookModel book) async {
    try {
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(book.id)
          .update(book.toFirestore());
    } catch (e) {
      AppLogger.error('Update book error', error: e);
      rethrow;
    }
  }

  // Delete book
  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .delete();
    } catch (e) {
      AppLogger.error('Delete book error', error: e);
      rethrow;
    }
  }

  // Publish/Unpublish book
  Future<void> setBookPublished(String bookId, bool isPublished) async {
    try {
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .update({
        'isPublished': isPublished,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.error('Set book published error', error: e);
      rethrow;
    }
  }

  // Get all books (including unpublished) for admin
  Future<List<BookModel>> getAllBooks({
    int limit = 50,
    DocumentSnapshot? startAfter,
    String? searchQuery,
    String? category,
    bool? isPublished,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.booksCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();

      List<BookModel> books = snapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .toList();

      // Filter by search query if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final queryLower = searchQuery.toLowerCase();
        books = books.where((book) {
          return book.title.toLowerCase().contains(queryLower) ||
              book.authors.any((author) => author.toLowerCase().contains(queryLower)) ||
              (book.description != null && book.description!.toLowerCase().contains(queryLower)) ||
              book.categories.any((cat) => cat.toLowerCase().contains(queryLower));
        }).toList();
      }

      // Filter by category
      if (category != null && category.isNotEmpty) {
        books = books.where((book) {
          return book.categories.contains(category);
        }).toList();
      }

      // Filter by published status
      if (isPublished != null) {
        books = books.where((book) {
          return book.isPublished == isPublished;
        }).toList();
      }

      // Filter by date range
      if (dateFrom != null) {
        books = books.where((book) {
          return book.createdAt.isAfter(dateFrom.subtract(const Duration(days: 1))) ||
              book.createdAt.isAtSameMomentAs(dateFrom);
        }).toList();
      }

      if (dateTo != null) {
        books = books.where((book) {
          return book.createdAt.isBefore(dateTo.add(const Duration(days: 1))) ||
              book.createdAt.isAtSameMomentAs(dateTo);
        }).toList();
      }

      return books;
    } catch (e) {
      AppLogger.error('Get all books error', error: e);
      rethrow;
    }
  }
}

