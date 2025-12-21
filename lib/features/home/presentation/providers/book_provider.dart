import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/book_repository.dart';
import '../../../../data/models/book_model.dart';

/// Book repository provider
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository();
});

/// Featured books provider
final featuredBooksProvider = FutureProvider<List<BookModel>>((ref) async {
  final repository = ref.read(bookRepositoryProvider);
  return repository.getFeaturedBooks(limit: 10);
});

/// Books provider with pagination
final booksProvider = FutureProvider.family<List<BookModel>, Map<String, dynamic>>((ref, params) async {
  final repository = ref.read(bookRepositoryProvider);
  return repository.getBooks(
    limit: params['limit'] as int? ?? 20,
    category: params['category'] as String?,
    searchQuery: params['searchQuery'] as String?,
  );
});

/// Book by ID provider
final bookByIdProvider = FutureProvider.family<BookModel?, String>((ref, bookId) async {
  final repository = ref.read(bookRepositoryProvider);
  return repository.getBookById(bookId);
});

/// Books by category provider
final booksByCategoryProvider = FutureProvider.family<List<BookModel>, String>((ref, category) async {
  final repository = ref.read(bookRepositoryProvider);
  return repository.getBooksByCategory(category);
});

/// Search books provider
final searchBooksProvider = FutureProvider.family<List<BookModel>, String>((ref, query) async {
  final repository = ref.read(bookRepositoryProvider);
  if (query.isEmpty) return [];
  return repository.searchBooks(query);
});

/// New releases provider
final newReleasesProvider = FutureProvider<List<BookModel>>((ref) async {
  final repository = ref.read(bookRepositoryProvider);
  return repository.getNewReleases(limit: 10);
});

/// Hot this week provider
final hotThisWeekProvider = FutureProvider<List<BookModel>>((ref) async {
  final repository = ref.read(bookRepositoryProvider);
  return repository.getHotThisWeek(limit: 10);
});

/// Rising stars provider
final risingStarsProvider = FutureProvider<List<BookModel>>((ref) async {
  final repository = ref.read(bookRepositoryProvider);
  return repository.getRisingStars(limit: 10);
});

/// Editor's picks provider
final editorsPicksProvider = FutureProvider<List<BookModel>>((ref) async {
  final repository = ref.read(bookRepositoryProvider);
  return repository.getEditorsPicks(limit: 10);
});

