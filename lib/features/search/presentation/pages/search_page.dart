import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/top_navigation_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/preferences_service.dart';
import '../widgets/search_filters_dialog.dart';

///  Search Page với design giống Wattpad & Waka
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String? _selectedCategory;
  double? _minRating;
  String? _authorFilter;
  String _sortBy = 'relevance'; // relevance, title, rating, date, popularity
  List<String> _searchHistory = [];
  final List<String> _popularSearches = [
    'Romance',
    'Fantasy',
    'Mystery',
    'Science Fiction',
    'Historical Fiction',
  ];
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    // Auto focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    try {
      final prefsService = PreferencesService();
      await prefsService.init();
      final history = await prefsService.getSearchHistory();
      if (mounted) {
        setState(() {
          _searchHistory = history;
        });
      }
    } catch (e) {
      // If error, just use empty list
      if (mounted) {
        setState(() {
          _searchHistory = [];
        });
      }
    }
  }

  Future<void> _saveSearchHistory(String query) async {
    if (query.isEmpty) return;
    try {
      final prefsService = PreferencesService();
      await prefsService.init();
      await prefsService.addToSearchHistory(query);

      // Reload to update UI
      await _loadSearchHistory();
    } catch (e) {
      // If error, just update local state
      if (!_searchHistory.contains(query)) {
        setState(() {
          _searchHistory.insert(0, query);
          if (_searchHistory.length > 10) {
            _searchHistory = _searchHistory.take(10).toList();
          }
        });
      }
    }
  }

  Future<void> _clearSearchHistory() async {
    try {
      final prefsService = PreferencesService();
      await prefsService.init();
      await prefsService.clearSearchHistory();
      if (mounted) {
        setState(() {
          _searchHistory = [];
        });
      }
    } catch (e) {
      // If error, just clear local state
      if (mounted) {
        setState(() {
          _searchHistory = [];
        });
      }
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
        _showFilters =
            _selectedCategory != null ||
            _minRating != null ||
            _authorFilter != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavigationBar(),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search books, authors, categories...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? InteractiveIconButton(
                                icon: Icons.clear,
                                onPressed: _clearSearch,
                                tooltip: 'Clear',
                                size: 40,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _performSearch,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Filter button
                Stack(
                  children: [
                    InteractiveIconButton(
                      icon: Icons.tune,
                      onPressed: _showFiltersDialog,
                      tooltip: 'Filters',
                      size: 40,
                    ),
                    if (_showFilters)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Body
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_searchQuery.isEmpty) {
      return _buildSearchSuggestions();
    }

    return _buildSearchResults();
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search History
          if (_searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                InteractiveButton(
                  label: 'Clear',
                  icon: Icons.clear,
                  onPressed: _clearSearchHistory,
                  isOutlined: true,
                  height: 36,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
                  avatar: const Icon(Icons.history, size: 18),
                  onPressed: () {
                    _searchController.text = query;
                    _performSearch(query);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],

          // Popular Searches
          Text(
            'Popular Searches',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((query) {
              return ActionChip(
                label: Text(query),
                avatar: const Icon(Icons.trending_up, size: 18),
                onPressed: () {
                  _searchController.text = query;
                  _performSearch(query);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Categories
          Text(
            'Browse by Category',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children:
                [
                  'Fiction',
                  'Non-Fiction',
                  'Science',
                  'History',
                  'Romance',
                  'Mystery',
                ].map((category) {
                  return AppCard(
                    margin: EdgeInsets.zero,
                    onTap: () {
                      _searchController.text = category;
                      _performSearch(category);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.category, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchResultsAsync = ref.watch(searchBooksProvider(_searchQuery));

    return Column(
      children: [
        // Active filters và sort
        if (_showFilters || _searchQuery.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.withOpacity(0.1),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_list, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (_selectedCategory != null)
                            Chip(
                              label: Text('Category: $_selectedCategory'),
                              onDeleted: () {
                                setState(() {
                                  _selectedCategory = null;
                                  _showFilters =
                                      _minRating != null ||
                                      _authorFilter != null;
                                });
                              },
                            ),
                          if (_minRating != null)
                            Chip(
                              label: Text(
                                'Rating: ${_minRating!.toStringAsFixed(1)}+',
                              ),
                              onDeleted: () {
                                setState(() {
                                  _minRating = null;
                                  _showFilters =
                                      _selectedCategory != null ||
                                      _authorFilter != null;
                                });
                              },
                            ),
                          if (_authorFilter != null &&
                              _authorFilter!.isNotEmpty)
                            Chip(
                              label: Text('Author: $_authorFilter'),
                              onDeleted: () {
                                setState(() {
                                  _authorFilter = null;
                                  _showFilters =
                                      _selectedCategory != null ||
                                      _minRating != null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                    // Sort button
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.sort,
                        size: 20,
                        color: Colors.blue,
                      ),
                      onSelected: (value) {
                        setState(() {
                          _sortBy = value;
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'relevance',
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 18),
                              SizedBox(width: 8),
                              Text('Relevance'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'title',
                          child: Row(
                            children: [
                              Icon(Icons.sort_by_alpha, size: 18),
                              SizedBox(width: 8),
                              Text('Title (A-Z)'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'title_desc',
                          child: Row(
                            children: [
                              Icon(Icons.sort_by_alpha, size: 18),
                              SizedBox(width: 8),
                              Text('Title (Z-A)'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'rating',
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 18),
                              SizedBox(width: 8),
                              Text('Rating'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'date',
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 18),
                              SizedBox(width: 8),
                              Text('Newest'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'popularity',
                          child: Row(
                            children: [
                              Icon(Icons.trending_up, size: 18),
                              SizedBox(width: 8),
                              Text('Popularity'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Search results
        Expanded(
          child: searchResultsAsync.when(
            data: (books) {
              // Apply filters
              var filteredBooks = books;

              if (_selectedCategory != null) {
                filteredBooks = filteredBooks.where((book) {
                  return book.categories.contains(_selectedCategory);
                }).toList();
              }

              if (_minRating != null) {
                filteredBooks = filteredBooks.where((book) {
                  return book.averageRating != null &&
                      book.averageRating! >= _minRating!;
                }).toList();
              }

              if (_authorFilter != null && _authorFilter!.isNotEmpty) {
                filteredBooks = filteredBooks.where((book) {
                  return book.authors.any(
                    (author) => author.toLowerCase().contains(
                      _authorFilter!.toLowerCase(),
                    ),
                  );
                }).toList();
              }

              // Apply sorting
              filteredBooks.sort((a, b) {
                switch (_sortBy) {
                  case 'title':
                    return a.title.compareTo(b.title);
                  case 'title_desc':
                    return b.title.compareTo(a.title);
                  case 'rating':
                    final ratingA = a.averageRating ?? 0;
                    final ratingB = b.averageRating ?? 0;
                    return ratingB.compareTo(ratingA);
                  case 'date':
                    return b.createdAt.compareTo(a.createdAt);
                  case 'popularity':
                    return b.totalReads.compareTo(a.totalReads);
                  default: // relevance
                    // Sort by relevance (rating + popularity)
                    final scoreA =
                        (a.averageRating ?? 0) * 0.6 +
                        (a.totalReads / 1000) * 0.4;
                    final scoreB =
                        (b.averageRating ?? 0) * 0.6 +
                        (b.totalReads / 1000) * 0.4;
                    return scoreB.compareTo(scoreA);
                }
              });

              if (filteredBooks.isEmpty) {
                return EmptyState(
                  title: 'No books found',
                  message: 'Try adjusting your search or filters',
                  icon: Icons.search_off,
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(searchBooksProvider(_searchQuery));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: AppCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            onTap: () => context.push(
                              '/book/${filteredBooks[index].id}',
                            ),
                            child: Row(
                              children: [
                                // Book cover
                                Container(
                                  width: 80,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[300],
                                  ),
                                  child:
                                      filteredBooks[index].coverImageUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            filteredBooks[index].coverImageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.book),
                                          ),
                                        )
                                      : const Icon(Icons.book),
                                ),
                                const SizedBox(width: 16),
                                // Book info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        filteredBooks[index].title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (filteredBooks[index]
                                          .authors
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          filteredBooks[index].authors.join(
                                            ', ',
                                          ),
                                          style: TextStyle(
                                            color: AppColors.textSecondaryLight,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      if (filteredBooks[index].averageRating !=
                                          null) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Colors.amber,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              filteredBooks[index]
                                                  .averageRating!
                                                  .toStringAsFixed(1),
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
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
                    );
                  },
                ),
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
          ),
        ),
      ],
    );
  }
}
