import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/top_navigation_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../data/models/book_model.dart';
import '../../../home/presentation/providers/book_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          // Header với filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    InteractiveButton(
                      icon: Icons.arrow_back,
                      onPressed: () => context.pop(),
                      isIconButton: true,
                      iconColor: AppColors.iconLight,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Quản Lý Sách',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                      ),
                    ),
                    InteractiveButton(
                      label: 'Upload Sách',
                      icon: Icons.add,
                      onPressed: () => context.push('/admin/upload-book'),
                      gradient: AppColors.primaryGradient,
                      height: 40,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search và filters
                Row(
                  children: [
                    Expanded(
                      child: TextField(
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
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _selectedCategory,
                      hint: const Text('Thể loại'),
                      items:
                          [
                            'All',
                            'Fiction',
                            'Non-Fiction',
                            'Science',
                            'History',
                            'Romance',
                            'Mystery',
                            'Fantasy',
                          ].map((category) {
                            return DropdownMenuItem(
                              value: category == 'All' ? null : category,
                              child: Text(category),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    InteractiveButton(
                      icon: _isGridView ? Icons.view_list : Icons.grid_view,
                      onPressed: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                      isIconButton: true,
                      iconColor: AppColors.iconLight,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Books list
          Expanded(child: _buildBooksList()),
        ],
      ),
    );
  }

  Widget _buildBooksList() {
    final booksAsync = ref.watch(
      allBooksProvider({
        'searchQuery': _searchQuery.isEmpty ? null : _searchQuery,
        'category': _selectedCategory,
        'isPublished': _publishedStatus,
        'dateFrom': _dateFrom,
        'dateTo': _dateTo,
      }),
    );

    return booksAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return _isGridView
              ? GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => const ShimmerBookCard(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5,
                  itemBuilder: (context, index) => const ShimmerListItem(),
                );
        }

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

        return _isGridView ? _buildGridView(books) : _buildListView(books);
      },
      loading: () => _isGridView
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => const ShimmerBookCard(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) => const ShimmerListItem(),
            ),
      error: (error, stack) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(
          allBooksProvider({
            'searchQuery': _searchQuery.isEmpty ? null : _searchQuery,
            'category': _selectedCategory,
            'isPublished': _publishedStatus,
            'dateFrom': _dateFrom,
            'dateTo': _dateTo,
          }),
        ),
      ),
    );
  }

  Widget _buildListView(List<BookModel> books) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
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
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InteractiveButton(
                        icon: Icons.menu_book,
                        onPressed: () {
                          context.push(
                            '/admin/manage-chapters?bookId=${book.id}',
                          );
                        },
                        isIconButton: true,
                        iconColor: AppColors.primary,
                        tooltip: 'Manage Chapters',
                      ),
                      const SizedBox(width: 8),
                      InteractiveButton(
                        icon: Icons.edit,
                        onPressed: () {
                          context.push('/admin/edit-book/${book.id}');
                        },
                        isIconButton: true,
                        iconColor: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      InteractiveButton(
                        icon: Icons.delete,
                        onPressed: () {
                          _showDeleteConfirmation(context, ref, book);
                        },
                        isIconButton: true,
                        iconColor: Colors.red,
                      ),
                    ],
                  ),
            onTap: () {
              context.push('/book/${book.id}');
            },
          ),
        );
      },
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
                ref.invalidate(
                  allBooksProvider({
                    'searchQuery': _searchQuery.isEmpty ? null : _searchQuery,
                    'category': _selectedCategory,
                    'isPublished': _publishedStatus,
                    'dateFrom': _dateFrom,
                    'dateTo': _dateTo,
                  }),
                );
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
      );
  }

  Widget _buildGridView(List<BookModel> books) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
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
                      color: AppColors.textSecondaryLight,
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
}

// Provider for all books (admin) with advanced filters
final allBooksProvider =
    FutureProvider.family<List<BookModel>, Map<String, dynamic>>((
      ref,
      filters,
    ) async {
      final repository = ref.read(bookRepositoryProvider);
      return repository.getAllBooks(
        limit: 100,
        searchQuery: filters['searchQuery'] as String?,
        category: filters['category'] as String?,
        isPublished: filters['isPublished'] as bool?,
        dateFrom: filters['dateFrom'] as DateTime?,
        dateTo: filters['dateTo'] as DateTime?,
      );
    });
