import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../data/models/book_model.dart';
import '../../../../data/models/chapter_model.dart';
import '../../../../data/repositories/chapter_repository.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../../../../core/services/export_service.dart';
import 'manage_categories_page.dart'; // For categoriesProvider

/// Trang quản lý sách với CRUD operations
class ManageBooksPage extends ConsumerStatefulWidget {
  const ManageBooksPage({super.key});

  @override
  ConsumerState<ManageBooksPage> createState() => _ManageBooksPageState();
}

class _ManageBooksPageState extends ConsumerState<ManageBooksPage> {
  String _searchQuery = '';
  String? _selectedCategory;
  bool? _publishedStatus;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _isGridView = false;
  final Set<String> _selectedBookIds = {};
  // ignore: prefer_final_fields
  bool _isSelectionMode = false;
  final Map<String, bool> _expandedBooks = {};
  String _sortBy = 'createdAt'; // createdAt, rating, views, title
  bool _sortDescending = true;
  int _currentLimit = 50; // Pagination limit
  List<BookModel> _currentBooks = []; // Current books list for export
  double? _minRating;
  double? _maxRating;
  int? _minViews;
  int? _maxViews;
  bool _showAdvancedFilters = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveUtils.isMobile(context);
        final padding = ResponsiveUtils.pagePadding(context);

        return Column(
          children: [
            Container(
              color: Theme.of(context).cardColor,
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMobile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleText(context),
                        const SizedBox(height: 12),
                        if (_isSelectionMode && _selectedBookIds.isNotEmpty)
                          _buildBulkActions(context, isMobile)
                        else
                          SizedBox(
                            width: double.infinity,
                            child: _buildPrimaryButton(context),
                          ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(child: _buildTitleText(context)),
                        const SizedBox(width: 16),
                        if (_isSelectionMode && _selectedBookIds.isNotEmpty)
                          _buildBulkActions(context, isMobile)
                        else
                          _buildPrimaryButton(context),
                      ],
                    ),
                  if (!_isSelectionMode) ...[
                    if (isMobile) ...[
                      const SizedBox(height: 12),
                      _buildSearchField(),
                      const SizedBox(height: 12),
                      _buildCategoryDropdown(isMobile),
                      const SizedBox(height: 12),
                      _buildSortDropdown(isMobile),
                      const SizedBox(height: 12),
                      _buildAdvancedFiltersToggle(isMobile),
                      if (_showAdvancedFilters) ...[
                        const SizedBox(height: 12),
                        _buildAdvancedFilters(isMobile),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildViewToggle()),
                          const SizedBox(width: 8),
                          InteractiveButton(
                            icon: Icons.checklist,
                            label: 'Chọn nhiều',
                            onPressed: () {
                              setState(() {
                                _isSelectionMode = true;
                                _selectedBookIds.clear();
                              });
                            },
                            isOutlined: true,
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.download, color: Colors.white),
                            onSelected: (value) => _exportBooks(value),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'csv',
                                child: Row(
                                  children: [
                                    Icon(Icons.table_chart),
                                    SizedBox(width: 8),
                                    Text('Export CSV'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'json',
                                child: Row(
                                  children: [
                                    Icon(Icons.code),
                                    SizedBox(width: 8),
                                    Text('Export JSON'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildSearchField()),
                          const SizedBox(width: 12),
                          _buildCategoryDropdown(isMobile),
                          const SizedBox(width: 12),
                          _buildSortDropdown(isMobile),
                          const SizedBox(width: 12),
                          _buildAdvancedFiltersToggle(isMobile),
                          const SizedBox(width: 12),
                          _buildViewToggle(),
                          const SizedBox(width: 8),
                          InteractiveButton(
                            icon: Icons.checklist,
                            label: 'Chọn nhiều',
                            onPressed: () {
                              setState(() {
                                _isSelectionMode = true;
                                _selectedBookIds.clear();
                              });
                            },
                            isOutlined: true,
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.download, color: Colors.white),
                            onSelected: (value) => _exportBooks(value),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'csv',
                                child: Row(
                                  children: [
                                    Icon(Icons.table_chart),
                                    SizedBox(width: 8),
                                    Text('Export CSV'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'json',
                                child: Row(
                                  children: [
                                    Icon(Icons.code),
                                    SizedBox(width: 8),
                                    Text('Export JSON'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ] else ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Đã chọn ${_selectedBookIds.length} sách',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        InteractiveButton(
                          icon: Icons.close,
                          label: 'Hủy',
                          onPressed: () {
                            setState(() {
                              _isSelectionMode = false;
                              _selectedBookIds.clear();
                            });
                          },
                          isOutlined: true,
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _buildBooksList(
                isMobile: isMobile,
                maxWidth: constraints.maxWidth,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitleText(BuildContext context) {
    return Text(
      'Quản Lý Sách',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text
          ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return InteractiveButton(
      label: 'Upload Sách',
      icon: Icons.add,
      onPressed: () => context.push('/admin/upload-book'),
      gradient: AppColors.primaryGradient,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm kiếm sách...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildCategoryDropdown(bool isMobile) {
    // Get categories from provider (from manage_categories_page)
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return categoriesAsync.when(
      data: (categories) {
        // Ensure no duplicates and add "All" option
        final allCategories = ['All', ...categories.toSet()..remove('All')]..sort((a, b) {
          if (a == 'All') return -1;
          if (b == 'All') return 1;
          return a.compareTo(b);
        });
        
        // Ensure selected category exists in items, otherwise set to null
        final validSelectedCategory = _selectedCategory != null && 
            allCategories.contains(_selectedCategory) 
            ? _selectedCategory 
            : null;
        
        final dropdown = DropdownButton<String>(
          value: validSelectedCategory == 'All' ? null : validSelectedCategory,
          hint: const Text('Thể loại', style: TextStyle(color: Colors.black87)),
          style: const TextStyle(color: Colors.black87),
          dropdownColor: Colors.white,
          items: allCategories.map((category) {
            return DropdownMenuItem<String>(
              value: category == 'All' ? null : category,
              child: Text(category, style: const TextStyle(color: Colors.black87)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        );

        if (isMobile) {
          return SizedBox(
            width: double.infinity,
            child: dropdown,
          );
        }
        return dropdown;
      },
      loading: () => const SizedBox(
        width: 150,
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox(
        width: 150,
        height: 48,
        child: Center(child: Icon(Icons.error)),
      ),
    );
  }

  Widget _buildViewToggle() {
    return InteractiveButton(
      icon: _isGridView ? Icons.view_list : Icons.grid_view,
      onPressed: () {
        setState(() {
          _isGridView = !_isGridView;
        });
      },
      isIconButton: true,
      iconColor: Colors.white, // White icon
    );
  }

  Widget _buildSortDropdown(bool isMobile) {
    final sortOptions = {
      'createdAt': 'Ngày tạo',
      'title': 'Tiêu đề',
      'rating': 'Đánh giá',
      'views': 'Lượt xem',
    };

    final dropdown = DropdownButton<String>(
      value: _sortBy,
      hint: const Text('Sắp xếp', style: TextStyle(color: Colors.black87)),
      style: const TextStyle(color: Colors.black87),
      dropdownColor: Colors.white,
      items: sortOptions.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Row(
            children: [
              Text(entry.value, style: const TextStyle(color: Colors.black87)),
              const SizedBox(width: 8),
              if (_sortBy == entry.key)
                Icon(
                  _sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 16,
                  color: Colors.black87,
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            if (_sortBy == value) {
              _sortDescending = !_sortDescending;
            } else {
              _sortBy = value;
              _sortDescending = true;
            }
          });
        }
      },
    );

    if (isMobile) {
      return SizedBox(
        width: double.infinity,
        child: dropdown,
      );
    }
    return dropdown;
  }

  Widget _buildAdvancedFiltersToggle(bool isMobile) {
    return InteractiveButton(
      icon: _showAdvancedFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
      label: 'Lọc nâng cao',
      onPressed: () {
        setState(() {
          _showAdvancedFilters = !_showAdvancedFilters;
        });
      },
      isOutlined: !_showAdvancedFilters,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildAdvancedFilters(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lọc theo Đánh giá',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Từ',
                  hintText: '0.0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _minRating = double.tryParse(value);
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Đến',
                  hintText: '5.0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _maxRating = double.tryParse(value);
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Lọc theo Lượt xem',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Từ',
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _minViews = int.tryParse(value);
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Đến',
                  hintText: '10000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _maxViews = int.tryParse(value);
                  });
                },
              ),
            ),
          ],
        ),
        if (_minRating != null || _maxRating != null || _minViews != null || _maxViews != null) ...[
          const SizedBox(height: 12),
          InteractiveButton(
            icon: Icons.clear,
            label: 'Xóa bộ lọc',
            onPressed: () {
              setState(() {
                _minRating = null;
                _maxRating = null;
                _minViews = null;
                _maxViews = null;
              });
            },
            isOutlined: true,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ],
      ],
    );
  }

  Widget _buildBooksList({
    required bool isMobile,
    required double maxWidth,
  }) {
    // Create filter key string for provider (to avoid Map equality issues)
    // Using string key ensures proper caching and refresh behavior
    final filterKey = [
      _currentLimit.toString(),
      _searchQuery,
      _selectedCategory ?? '',
      _publishedStatus?.toString() ?? '',
      _dateFrom?.toIso8601String() ?? '',
      _dateTo?.toIso8601String() ?? '',
    ].join('|');
    
    final booksAsync = ref.watch(allBooksProvider(filterKey));

    return booksAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return EmptyState(
            title: 'Chưa có sách nào',
            message: 'Bắt đầu bằng cách upload sách mới',
            icon: Icons.library_books_outlined,
            action: InteractiveButton(
              label: 'Upload Sách',
              icon: Icons.add,
              onPressed: () => context.push('/admin/upload-book'),
              gradient: AppColors.primaryGradient,
            ),
          );
        }

        // Apply sorting
        final sortedBooks = List<BookModel>.from(books);
        sortedBooks.sort((a, b) {
          int comparison = 0;
          switch (_sortBy) {
            case 'title':
              comparison = a.title.compareTo(b.title);
              break;
            case 'rating':
              final ratingA = a.averageRating ?? 0;
              final ratingB = b.averageRating ?? 0;
              comparison = ratingA.compareTo(ratingB);
              break;
            case 'views':
              comparison = a.totalReads.compareTo(b.totalReads);
              break;
            case 'createdAt':
            default:
              comparison = a.createdAt.compareTo(b.createdAt);
              break;
          }
          return _sortDescending ? -comparison : comparison;
        });

        // Store current books for export
        _currentBooks = sortedBooks;

        final booksWidget = _isGridView
            ? _buildGridView(sortedBooks, maxWidth, isMobile)
            : _buildListView(sortedBooks);

        // Add Load More button if there are books
        if (sortedBooks.length >= _currentLimit) {
          return Column(
            children: [
              Expanded(child: booksWidget),
              Padding(
                padding: const EdgeInsets.all(16),
                child: InteractiveButton(
                  label: 'Tải thêm',
                  icon: Icons.expand_more,
                  onPressed: () {
                    setState(() {
                      _currentLimit += 50;
                    });
                  },
                  isOutlined: true,
                ),
              ),
            ],
          );
        }

        return booksWidget;
      },
      loading: () => _isGridView
          ? _buildLoadingGrid(maxWidth, isMobile)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) => const ShimmerListItem(),
            ),
      error: (error, stack) {
        debugPrint('Error loading books: $error');
        debugPrint('Stack trace: $stack');
        return ErrorState(
          message: error.toString(),
          onRetry: () {
            final retryFilters = <String, dynamic>{};
            if (_searchQuery.isNotEmpty) {
              retryFilters['searchQuery'] = _searchQuery;
            }
            if (_selectedCategory != null) {
              retryFilters['category'] = _selectedCategory;
            }
            if (_publishedStatus != null) {
              retryFilters['isPublished'] = _publishedStatus;
            }
            if (_dateFrom != null) {
              retryFilters['dateFrom'] = _dateFrom;
            }
            if (_dateTo != null) {
              retryFilters['dateTo'] = _dateTo;
            }
            final retryKey = [
              _currentLimit.toString(),
              _searchQuery,
              _selectedCategory ?? '',
              _publishedStatus?.toString() ?? '',
              _dateFrom?.toIso8601String() ?? '',
              _dateTo?.toIso8601String() ?? '',
            ].join('|');
            ref.invalidate(allBooksProvider(retryKey));
          },
        );
      },
    );
  }

  Widget _buildListView(List<BookModel> books) {
    final isMobile = ResponsiveUtils.isMobile(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final isExpanded = _expandedBooks[book.id] ?? false;
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 60,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: book.coverImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            book.coverImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(Icons.book),
                          ),
                        )
                      : const Icon(Icons.book),
                ),
                title: Text(
                  book.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  book.authors.isNotEmpty
                      ? book.authors.join(', ')
                      : 'Unknown Author',
                ),
                trailing: _isSelectionMode
                    ? null
                    : isMobile
                        ? IconButton(
                            icon: Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                            ),
                            onPressed: () {
                              setState(() {
                                _expandedBooks[book.id] = !isExpanded;
                              });
                            },
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _expandedBooks[book.id] = !isExpanded;
                                  });
                                },
                                tooltip: 'Chapters',
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: AppColors.primary,
                                onPressed: () {
                                  context.push('/admin/edit-book/${book.id}');
                                },
                                tooltip: 'Edit Book',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  _showDeleteConfirmation(context, ref, book);
                                },
                                tooltip: 'Delete Book',
                              ),
                            ],
                          ),
                onTap: () {
                  if (!_isSelectionMode) {
                    setState(() {
                      _expandedBooks[book.id] = !isExpanded;
                    });
                  }
                },
              ),
              if (isExpanded) _buildChaptersSection(book.id),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChaptersSection(String bookId) {
    final chaptersAsync = ref.watch(bookChaptersProvider(bookId));
    final isMobile = ResponsiveUtils.isMobile(context);

    return chaptersAsync.when(
      data: (chapters) {
        if (chapters.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Chưa có chapters nào',
                  style: TextStyle(color: Colors.white70), // White text
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: InteractiveButton(
                    label: 'Thêm Chapter',
                    icon: Icons.add,
                    onPressed: () {
                      context.push('/admin/edit-chapter?bookId=$bookId');
                    },
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chapters (${chapters.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  InteractiveButton(
                    label: 'Thêm',
                    icon: Icons.add,
                    onPressed: () {
                      context.push('/admin/edit-chapter?bookId=$bookId');
                    },
                    gradient: AppColors.primaryGradient,
                    height: 32,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return isMobile
                    ? _buildMobileChapterItem(chapter, bookId)
                    : _buildDesktopChapterItem(chapter, bookId);
              },
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Error: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildMobileChapterItem(ChapterModel chapter, String bookId) {
    return InkWell(
      onTap: () => _showChapterActions(context, ref, chapter, bookId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${chapter.chapterNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${chapter.content.length} ký tự • ${chapter.estimatedReadingTimeMinutes ?? 0} phút',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70, // White text
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondaryLight),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopChapterItem(ChapterModel chapter, String bookId) {
    return ListTile(
      dense: true,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            '${chapter.chapterNumber}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 12,
            ),
          ),
        ),
      ),
      title: Text(
        chapter.title,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        '${chapter.content.length} characters • ${chapter.estimatedReadingTimeMinutes ?? 0} min',
        style: const TextStyle(fontSize: 11),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
            onPressed: () {
              context.push(
                '/admin/edit-chapter?bookId=$bookId&chapterId=${chapter.id}',
              );
            },
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
            onPressed: () {
              _showDeleteChapterConfirmation(context, ref, chapter, bookId);
            },
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  void _showChapterActions(
    BuildContext context,
    WidgetRef ref,
    ChapterModel chapter,
    String bookId,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${chapter.chapterNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${chapter.content.length} ký tự',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70, // White text
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Chỉnh sửa'),
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/admin/edit-chapter?bookId=$bookId&chapterId=${chapter.id}',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteChapterConfirmation(context, ref, chapter, bookId);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteChapterConfirmation(
    BuildContext context,
    WidgetRef ref,
    ChapterModel chapter,
    String bookId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa chapter "${chapter.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final repository = ChapterRepository();
                await repository.deleteChapter(chapter.id);
                ref.invalidate(bookChaptersProvider(bookId));
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa chapter thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid(double maxWidth, bool isMobile) {
    final crossAxisCount = ResponsiveUtils.gridCountForWidth(
      maxWidth,
      minItemWidth: isMobile ? 160 : 220,
      maxCount: isMobile ? 2 : 4,
    );

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ShimmerBookCard(),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    BookModel book,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa sách "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final repository = ref.read(bookRepositoryProvider);
                await repository.deleteBook(book.id);
                // Invalidate with current filters
            final retryKey = [
              _currentLimit.toString(),
              _searchQuery,
              _selectedCategory ?? '',
              _publishedStatus?.toString() ?? '',
              _dateFrom?.toIso8601String() ?? '',
              _dateTo?.toIso8601String() ?? '',
            ].join('|');
            ref.invalidate(allBooksProvider(retryKey));
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa sách thành công')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(
    List<BookModel> books,
    double maxWidth,
    bool isMobile,
  ) {
    final crossAxisCount = ResponsiveUtils.gridCountForWidth(
      maxWidth,
      minItemWidth: isMobile ? 160 : 220,
      maxCount: isMobile ? 2 : 4,
    );

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return AppCard(
          onTap: () {
            if (_isSelectionMode) {
              setState(() {
                if (_selectedBookIds.contains(book.id)) {
                  _selectedBookIds.remove(book.id);
                } else {
                  _selectedBookIds.add(book.id);
                }
              });
            } else {
              context.push('/book/${book.id}');
            }
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
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
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.authors.isNotEmpty
                        ? book.authors.join(', ')
                        : 'Unknown',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70, // White text
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (_isSelectionMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Checkbox(
                    value: _selectedBookIds.contains(book.id),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedBookIds.add(book.id);
                        } else {
                          _selectedBookIds.remove(book.id);
                        }
                      });
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBulkActions(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InteractiveButton(
                  icon: Icons.delete,
                  label: 'Xóa',
                  onPressed: _selectedBookIds.isEmpty
                      ? null
                      : () => _showBulkDeleteConfirmation(context),
                  backgroundColor: Colors.red,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InteractiveButton(
                  icon: Icons.publish,
                  label: 'Xuất bản',
                  onPressed: _selectedBookIds.isEmpty
                      ? null
                      : () => _bulkPublishBooks(context, true),
                  gradient: AppColors.primaryGradient,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: InteractiveButton(
              icon: Icons.unpublished,
              label: 'Gỡ xuất bản',
              onPressed: _selectedBookIds.isEmpty
                  ? null
                  : () => _bulkPublishBooks(context, false),
              isOutlined: true,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        InteractiveButton(
          icon: Icons.delete,
          label: 'Xóa',
          onPressed: _selectedBookIds.isEmpty
              ? null
              : () => _showBulkDeleteConfirmation(context),
          backgroundColor: Colors.red,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        const SizedBox(width: 8),
        InteractiveButton(
          icon: Icons.publish,
          label: 'Xuất bản',
          onPressed: _selectedBookIds.isEmpty
              ? null
              : () => _bulkPublishBooks(context, true),
          gradient: AppColors.primaryGradient,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        const SizedBox(width: 8),
        InteractiveButton(
          icon: Icons.unpublished,
          label: 'Gỡ xuất bản',
          onPressed: _selectedBookIds.isEmpty
              ? null
              : () => _bulkPublishBooks(context, false),
          isOutlined: true,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ],
    );
  }

  void _showBulkDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa ${_selectedBookIds.length} sách đã chọn? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _bulkDeleteBooks(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _bulkDeleteBooks(BuildContext context) async {
    if (_selectedBookIds.isEmpty) return;

    try {
      final repository = ref.read(bookRepositoryProvider);
      int successCount = 0;
      int failCount = 0;

      for (final bookId in _selectedBookIds) {
        try {
          await repository.deleteBook(bookId);
          successCount++;
        } catch (e) {
          failCount++;
          debugPrint('Error deleting book $bookId: $e');
        }
      }

      // Invalidate providers
            final retryKey = [
              _currentLimit.toString(),
              _searchQuery,
              _selectedCategory ?? '',
              _publishedStatus?.toString() ?? '',
              _dateFrom?.toIso8601String() ?? '',
              _dateTo?.toIso8601String() ?? '',
            ].join('|');
            ref.invalidate(allBooksProvider(retryKey));

      setState(() {
        _isSelectionMode = false;
        _selectedBookIds.clear();
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failCount > 0
                  ? 'Đã xóa $successCount sách. $failCount sách xóa thất bại.'
                  : 'Đã xóa thành công $successCount sách.',
            ),
            backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa sách: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _bulkPublishBooks(BuildContext context, bool isPublished) async {
    if (_selectedBookIds.isEmpty) return;

    try {
      final repository = ref.read(bookRepositoryProvider);
      int successCount = 0;
      int failCount = 0;

      for (final bookId in _selectedBookIds) {
        try {
          await repository.setBookPublished(bookId, isPublished);
          successCount++;
        } catch (e) {
          failCount++;
          debugPrint('Error updating book $bookId: $e');
        }
      }

      // Invalidate providers
            final retryKey = [
              _currentLimit.toString(),
              _searchQuery,
              _selectedCategory ?? '',
              _publishedStatus?.toString() ?? '',
              _dateFrom?.toIso8601String() ?? '',
              _dateTo?.toIso8601String() ?? '',
            ].join('|');
            ref.invalidate(allBooksProvider(retryKey));

      setState(() {
        _isSelectionMode = false;
        _selectedBookIds.clear();
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failCount > 0
                  ? 'Đã ${isPublished ? "xuất bản" : "gỡ xuất bản"} $successCount sách. $failCount sách cập nhật thất bại.'
                  : 'Đã ${isPublished ? "xuất bản" : "gỡ xuất bản"} thành công $successCount sách.',
            ),
            backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật sách: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportBooks(String format) async {
    if (_currentBooks.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có dữ liệu để export'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      final exportService = ExportService();
      
      if (format == 'csv') {
        await exportService.exportBooksToCSV(_currentBooks);
      } else if (format == 'json') {
        await exportService.exportBooksToJSON(_currentBooks);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã export ${_currentBooks.length} sách ra $format'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Provider for all books (admin) with advanced filters
// Using String key instead of Map to avoid equality issues
final allBooksProvider =
    FutureProvider.family<List<BookModel>, String>((ref, filterKey) async {
      try {
        // Parse filter key back to parameters
        final parts = filterKey.split('|');
        final limit = int.tryParse(parts[0]) ?? 50;
        final searchQuery = parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null;
        final category = parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null;
        final isPublished = parts.length > 3 && parts[3].isNotEmpty ? (parts[3] == 'true') : null;
        final dateFrom = parts.length > 4 && parts[4].isNotEmpty ? DateTime.tryParse(parts[4]) : null;
        final dateTo = parts.length > 5 && parts[5].isNotEmpty ? DateTime.tryParse(parts[5]) : null;
        
        final repository = ref.read(bookRepositoryProvider);
        debugPrint('=== Loading books with filters ===');
        debugPrint('Limit: $limit');
        debugPrint('Search: $searchQuery');
        debugPrint('Category: $category');
        debugPrint('Published: $isPublished');
        debugPrint('DateFrom: $dateFrom');
        debugPrint('DateTo: $dateTo');
        
        final books = await repository.getAllBooks(
          limit: limit,
          searchQuery: searchQuery,
          category: category,
          isPublished: isPublished,
          dateFrom: dateFrom,
          dateTo: dateTo,
        );
        
        debugPrint('=== Loaded ${books.length} books ===');
        if (books.isEmpty) {
          debugPrint('WARNING: No books returned from repository');
        }
        return books;
      } catch (e, stackTrace) {
        // Log error with full details
        debugPrint('=== ERROR loading books ===');
        debugPrint('Error: $e');
        debugPrint('Stack trace: $stackTrace');
        // Re-throw để hiển thị error state trong UI
        rethrow;
      }
    });

// Provider cho chapters của một book (admin - includes unpublished)
final bookChaptersProvider = FutureProvider.family<List<ChapterModel>, String>((
  ref,
  bookId,
) async {
  final repository = ChapterRepository();
  return repository.getAllChaptersByBookId(bookId);
});
