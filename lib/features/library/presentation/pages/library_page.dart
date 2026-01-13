import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_breakpoints.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/top_navigation_bar.dart';
import '../providers/library_provider.dart';
import '../widgets/library_filters_dialog.dart';
import '../widgets/library_sort_dialog.dart';
import '../../../../data/models/library_item_model.dart';
import '../../../../data/models/book_model.dart';
import '../../../home/presentation/providers/book_provider.dart';

/// Library Page với design giống Wattpad & Waka
class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = false;
  String _sortBy = 'date_added_desc';
  String? _selectedCategory;
  double? _minRating;
  String? _selectedAuthor;
  String? _dateFilter = 'All Time';
  String? _progressFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes to update icon colors
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavigationBar(),
      body: Column(
        children: [
          // Library header với tabs
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        AppStrings.myLibrary,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Row(
                        children: [
                          // Filter button
                          Stack(
                            children: [
                              InteractiveIconButton(
                                icon: Icons.filter_list,
                                onPressed: _showFiltersDialog,
                                tooltip: 'Filters',
                                size: 40,
                                iconColor: AppColors.iconLight,
                              ),
                              if (_hasActiveFilters())
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
                          // Sort button
                          InteractiveIconButton(
                            icon: Icons.sort,
                            onPressed: _showSortDialog,
                            tooltip: 'Sort',
                            size: 40,
                            iconColor: AppColors.iconLight,
                          ),
                          // View toggle
                          InteractiveIconButton(
                            icon: _isGridView
                                ? Icons.view_list
                                : Icons.grid_view,
                            onPressed: () {
                              setState(() {
                                _isGridView = !_isGridView;
                              });
                            },
                            tooltip: _isGridView ? 'List view' : 'Grid view',
                            size: 40,
                            iconColor: AppColors.iconLight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textPrimaryLight.withValues(
                    alpha: 0.7,
                  ),
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(
                      text: 'Reading',
                      icon: Icon(
                        Icons.menu_book,
                        color: _tabController.index == 0
                            ? AppColors.primary
                            : AppColors.textPrimaryLight.withValues(alpha: 0.7),
                      ),
                    ),
                    Tab(
                      text: 'Completed',
                      icon: Icon(
                        Icons.check_circle,
                        color: _tabController.index == 1
                            ? AppColors.primary
                            : AppColors.textPrimaryLight.withValues(alpha: 0.7),
                      ),
                    ),
                    Tab(
                      text: 'Want to Read',
                      icon: Icon(
                        Icons.bookmark_border,
                        color: _tabController.index == 2
                            ? AppColors.primary
                            : AppColors.textPrimaryLight.withValues(alpha: 0.7),
                      ),
                    ),
                    Tab(
                      text: 'All',
                      icon: Icon(
                        Icons.library_books,
                        color: _tabController.index == 3
                            ? AppColors.primary
                            : AppColors.textPrimaryLight.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLibraryList(AppConstants.bookStatusReading),
                _buildLibraryList(AppConstants.bookStatusCompleted),
                _buildLibraryList(AppConstants.bookStatusWantToRead),
                _buildLibraryList(null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedCategory != null ||
        _minRating != null ||
        _selectedAuthor != null ||
        _dateFilter != 'All Time' ||
        _progressFilter != 'All';
  }

  Future<void> _showFiltersDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LibraryFiltersDialog(
        selectedCategory: _selectedCategory,
        minRating: _minRating,
        selectedAuthor: _selectedAuthor,
        dateFilter: _dateFilter,
        progressFilter: _progressFilter,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result['category'];
        _minRating = result['minRating'];
        _selectedAuthor = result['author'];
        _dateFilter = result['dateFilter'] ?? 'All Time';
        _progressFilter = result['progressFilter'] ?? 'All';
      });
    }
  }

  Future<void> _showSortDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => LibrarySortDialog(currentSort: _sortBy),
    );

    if (result != null) {
      setState(() {
        _sortBy = result;
      });
    }
  }

  List<LibraryItemModel> _applyFiltersAndSort(
    List<LibraryItemModel> items,
    List<BookModel> books,
  ) {
    var filtered = items;

    // Create a map for quick lookup
    final bookMap = <String, BookModel>{};
    for (final book in books) {
      bookMap[book.id] = book;
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((item) {
        final book = bookMap[item.bookId];
        return book != null && book.categories.contains(_selectedCategory);
      }).toList();
    }

    // Apply rating filter
    if (_minRating != null) {
      filtered = filtered.where((item) {
        final book = bookMap[item.bookId];
        return book != null &&
            book.averageRating != null &&
            book.averageRating! >= _minRating!;
      }).toList();
    }

    // Apply author filter
    if (_selectedAuthor != null && _selectedAuthor!.isNotEmpty) {
      filtered = filtered.where((item) {
        final book = bookMap[item.bookId];
        return book != null &&
            book.authors.any(
              (author) =>
                  author.toLowerCase().contains(_selectedAuthor!.toLowerCase()),
            );
      }).toList();
    }

    // Apply progress filter
    if (_progressFilter != null && _progressFilter != 'All') {
      final progressRanges = {
        '0-25%': (0.0, 0.25),
        '25-50%': (0.25, 0.50),
        '50-75%': (0.50, 0.75),
        '75-100%': (0.75, 1.0),
      };

      final range = progressRanges[_progressFilter];
      if (range != null) {
        filtered = filtered.where((item) {
          return item.progress >= range.$1 && item.progress <= range.$2;
        }).toList();
      }
    }

    // Sort items
    filtered.sort((a, b) {
      final bookA = bookMap[a.bookId];
      final bookB = bookMap[b.bookId];

      if (bookA == null || bookB == null) return 0;

      switch (_sortBy) {
        case 'title_asc':
          return bookA.title.compareTo(bookB.title);
        case 'title_desc':
          return bookB.title.compareTo(bookA.title);
        case 'author_asc':
          final authorA = bookA.authors.isNotEmpty ? bookA.authors.first : '';
          final authorB = bookB.authors.isNotEmpty ? bookB.authors.first : '';
          return authorA.compareTo(authorB);
        case 'author_desc':
          final authorA = bookA.authors.isNotEmpty ? bookA.authors.first : '';
          final authorB = bookB.authors.isNotEmpty ? bookB.authors.first : '';
          return authorB.compareTo(authorA);
        case 'date_added_desc':
          return b.addedAt.compareTo(a.addedAt);
        case 'date_added_asc':
          return a.addedAt.compareTo(b.addedAt);
        case 'progress_desc':
          return b.progress.compareTo(a.progress);
        case 'progress_asc':
          return a.progress.compareTo(b.progress);
        case 'rating_desc':
          final ratingA = bookA.averageRating ?? 0;
          final ratingB = bookB.averageRating ?? 0;
          return ratingB.compareTo(ratingA);
        case 'rating_asc':
          final ratingA = bookA.averageRating ?? 0;
          final ratingB = bookB.averageRating ?? 0;
          return ratingA.compareTo(ratingB);
        default:
          return b.addedAt.compareTo(a.addedAt);
      }
    });

    return filtered;
  }

  Widget _buildLibraryList(String? status) {
    final libraryItemsAsync = ref.watch(libraryItemsProvider(status));

    return libraryItemsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(
            title: 'No books in this section',
            message: 'Start reading to build your library',
            icon: Icons.library_books_outlined,
          );
        }

        // Get all books for filtering
        final bookIds = items.map((item) => item.bookId).toSet();
        final booksAsync = Future.wait(
          bookIds.map((id) => ref.read(bookByIdProvider(id).future)),
        );

        return FutureBuilder<List<BookModel?>>(
          future: booksAsync,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final books = snapshot.data!
                .where((book) => book != null)
                .cast<BookModel>()
                .toList();

            // Apply filters and sorting
            final filteredItems = _applyFiltersAndSort(items, books);

            if (filteredItems.isEmpty) {
              return EmptyState(
                title: 'No books match your filters',
                message: 'Try adjusting your filters',
                icon: Icons.filter_alt_off,
                action: InteractiveButton(
                  label: 'Clear Filters',
                  icon: Icons.clear,
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                      _minRating = null;
                      _selectedAuthor = null;
                      _dateFilter = 'All Time';
                      _progressFilter = 'All';
                    });
                  },
                  height: 40,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(libraryItemsProvider(status));
              },
              child: _isGridView
                  ? _buildGridView(filteredItems)
                  : _buildListView(filteredItems),
            );
          },
        );
      },
      loading: () => _isGridView
          ? LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = AppBreakpoints.gridColumns(width);
                final padding = AppBreakpoints.padding(width);

                return GridView.builder(
                  padding: EdgeInsets.all(padding),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => const ShimmerBookCard(),
                );
              },
            )
          : ListView.builder(
              padding: EdgeInsets.all(
                AppBreakpoints.padding(MediaQuery.of(context).size.width),
              ),
              itemCount: 5,
              itemBuilder: (context, index) => const ShimmerListItem(),
            ),
      error: (error, stack) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(libraryItemsProvider(status)),
      ),
    );
  }

  Widget _buildListView(List<LibraryItemModel> items) {
    final padding = AppBreakpoints.padding(MediaQuery.of(context).size.width);
    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: _buildLibraryItemCard(context, items[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<LibraryItemModel> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = AppBreakpoints.gridColumns(width);
        final padding = AppBreakpoints.padding(width);

        return GridView.builder(
          padding: EdgeInsets.all(padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: crossAxisCount,
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildLibraryItemGridCard(context, items[index]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLibraryItemCard(BuildContext context, LibraryItemModel item) {
    final bookAsync = ref.watch(bookByIdProvider(item.bookId));

    return bookAsync.when(
      data: (book) {
        if (book == null) return const SizedBox();

        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          onTap: () => context.push('/book/${book.id}'),
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
                child: Stack(
                  children: [
                    book.coverImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              book.coverImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(Icons.book),
                            ),
                          )
                        : const Icon(Icons.book),
                    // Progress indicator
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: item.progress.clamp(0.0, 1.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Book info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.authors.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.authors.join(', '),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              InteractiveIconButton(
                icon: Icons.more_vert,
                onPressed: () {
                  // TODO: Implement menu
                },
                tooltip: 'More options',
                size: 40,
              ),
            ],
          ),
        );
      },
      loading: () => const ShimmerListItem(),
      error: (_, _) => const SizedBox(),
    );
  }

  Widget _buildLibraryItemGridCard(
    BuildContext context,
    LibraryItemModel item,
  ) {
    final bookAsync = ref.watch(bookByIdProvider(item.bookId));

    return bookAsync.when(
      data: (book) {
        if (book == null) return const SizedBox();

        return AppCard(
          onTap: () => context.push('/book/${book.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                      ),
                      child: book.coverImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                book.coverImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.book),
                              ),
                            )
                          : const Icon(Icons.book),
                    ),
                    // Progress indicator
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: item.progress.clamp(0.0, 1.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                book.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimaryLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${(item.progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const ShimmerBookCard(),
      error: (_, _) => const SizedBox(),
    );
  }
}
