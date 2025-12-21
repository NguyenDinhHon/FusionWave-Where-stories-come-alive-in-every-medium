import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../data/models/book_model.dart';
import '../widgets/search_filters_dialog.dart';

/// Enhanced SearchPage with filters and suggestions
class EnhancedSearchPage extends ConsumerStatefulWidget {
  const EnhancedSearchPage({super.key});

  @override
  ConsumerState<EnhancedSearchPage> createState() => _EnhancedSearchPageState();
}

class _EnhancedSearchPageState extends ConsumerState<EnhancedSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String? _selectedCategory;
  double? _minRating;
  String? _authorFilter;
  List<String> _searchHistory = [];
  bool _showFilters = false;
  
  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  void _loadSearchHistory() {
    // TODO: Load from SharedPreferences
    _searchHistory = [];
  }
  
  void _saveSearchHistory(String query) {
    if (query.isEmpty) return;
    if (!_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
      });
      // TODO: Save to SharedPreferences
    }
  }
  
  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    if (query.isNotEmpty) {
      _saveSearchHistory(query);
    }
  }
  
  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
      _minRating = null;
      _authorFilter = null;
      _searchController.clear();
    });
  }
  
  Future<void> _showFiltersDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SearchFiltersDialog(
        initialCategory: _selectedCategory,
        minRating: _minRating,
        author: _authorFilter,
      ),
    );
    
    if (result != null) {
      setState(() {
        _selectedCategory = result['category'];
        _minRating = result['minRating'];
        _authorFilter = result['author'];
        _showFilters = _selectedCategory != null || 
                      _minRating != null || 
                      _authorFilter != null;
      });
    }
  }
  
  List<BookModel> _filterBooks(List<BookModel> books) {
    var filtered = books;
    
    if (_selectedCategory != null) {
      filtered = filtered.where((book) => 
        book.categories.contains(_selectedCategory)
      ).toList();
    }
    
    if (_minRating != null && _minRating! > 0) {
      filtered = filtered.where((book) => 
        book.averageRating != null && book.averageRating! >= _minRating!
      ).toList();
    }
    
    if (_authorFilter != null && _authorFilter!.isNotEmpty) {
      final authorLower = _authorFilter!.toLowerCase();
      filtered = filtered.where((book) => 
        book.authors.any((author) => 
          author.toLowerCase().contains(authorLower)
        )
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showFilters ? Theme.of(context).primaryColor : null,
            ),
            onPressed: _showFiltersDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search books, authors, categories...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  onSubmitted: _performSearch,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      _clearSearch();
                    }
                  },
                ),
                
                // Active Filters
                if (_showFilters) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_selectedCategory != null)
                        Chip(
                          label: Text('Category: $_selectedCategory'),
                          onDeleted: () {
                            setState(() {
                              _selectedCategory = null;
                              _showFilters = _minRating != null || _authorFilter != null;
                            });
                          },
                        ),
                      if (_minRating != null && _minRating! > 0)
                        Chip(
                          label: Text('Rating: ${_minRating!.toStringAsFixed(1)}+'),
                          onDeleted: () {
                            setState(() {
                              _minRating = null;
                              _showFilters = _selectedCategory != null || _authorFilter != null;
                            });
                          },
                        ),
                      if (_authorFilter != null && _authorFilter!.isNotEmpty)
                        Chip(
                          label: Text('Author: $_authorFilter'),
                          onDeleted: () {
                            setState(() {
                              _authorFilter = null;
                              _showFilters = _selectedCategory != null || _minRating != null;
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Search Results or Suggestions
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildSearchSuggestions()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchHistory.clear();
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.map((query) {
                return ActionChip(
                  label: Text(query),
                  onPressed: () {
                    _searchController.text = query;
                    _performSearch(query);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          const Text(
            'Popular Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              'Fiction',
              'Non-Fiction',
              'Science',
              'History',
              'Biography',
              'Fantasy',
            ].map((category) {
              return ActionChip(
                label: Text(category),
                onPressed: () {
                  setState(() {
                    _selectedCategory = category;
                    _showFilters = true;
                  });
                  _showFiltersDialog();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    final searchAsync = ref.watch(searchBooksProvider(_searchQuery));
    
    return searchAsync.when(
      data: (books) {
        final filteredBooks = _filterBooks(books);
        
        if (filteredBooks.isEmpty) {
          return EmptyState(
            title: 'No books found',
            message: 'Try adjusting your search or filters',
            icon: Icons.search_off,
            action: ElevatedButton(
              onPressed: _clearSearch,
              child: const Text('Clear Filters'),
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredBooks.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => context.push('/book/${filteredBooks[index].id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Book cover
                            Container(
                              width: 60,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: filteredBooks[index].coverImageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        filteredBooks[index].coverImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.book),
                                      ),
                                    )
                                  : const Icon(Icons.book),
                            ),
                            const SizedBox(width: 12),
                            // Book info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filteredBooks[index].title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (filteredBooks[index].authors.isNotEmpty)
                                    Text(
                                      filteredBooks[index].authors.join(', '),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  if (filteredBooks[index].categories.isNotEmpty)
                                    Wrap(
                                      spacing: 4,
                                      children: filteredBooks[index].categories.take(2).map((category) {
                                        return Chip(
                                          label: Text(
                                            category,
                                            style: const TextStyle(fontSize: 10),
                                          ),
                                          padding: EdgeInsets.zero,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        );
                                      }).toList(),
                                    ),
                                  if (filteredBooks[index].averageRating != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 14, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          filteredBooks[index].averageRating!.toStringAsFixed(1),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => const ShimmerListItem(),
      ),
      error: (error, stack) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(searchBooksProvider(_searchQuery)),
      ),
    );
  }
}

