import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/top_navigation_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../data/repositories/chapter_repository.dart';
import '../../../../data/models/chapter_model.dart';
import '../../../home/presentation/providers/book_provider.dart';

/// Provider cho chapters của một book (admin - includes unpublished)
final bookChaptersProvider = FutureProvider.family<List<ChapterModel>, String>((
  ref,
  bookId,
) async {
  final repository = ChapterRepository();
  return repository.getAllChaptersByBookId(bookId);
});

/// Trang quản lý chapters
class ManageChaptersPage extends ConsumerStatefulWidget {
  final String? bookId;

  const ManageChaptersPage({super.key, this.bookId});

  @override
  ConsumerState<ManageChaptersPage> createState() => _ManageChaptersPageState();
}

class _ManageChaptersPageState extends ConsumerState<ManageChaptersPage> {
  Set<String> _selectedChapterIds = {};
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    // If bookId is provided, show chapters for that book
    if (widget.bookId != null) {
      return _buildChaptersList(context, ref, widget.bookId!);
    }

    // Otherwise show book selection
    return Scaffold(
      appBar: const TopNavigationBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: AppCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.menu_book, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Chọn sách để quản lý chapters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                InteractiveButton(
                  label: 'Quay lại',
                  icon: Icons.arrow_back,
                  onPressed: () => context.pop(),
                  isOutlined: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChaptersList(
    BuildContext context,
    WidgetRef ref,
    String bookId,
  ) {
    final chaptersAsync = ref.watch(bookChaptersProvider(bookId));
    final bookAsync = ref.watch(bookByIdProvider(bookId));

    return Scaffold(
      appBar: const TopNavigationBar(),
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                InteractiveButton(
                  icon: Icons.arrow_back,
                  onPressed: () => context.pop(),
                  isIconButton: true,
                  iconColor: AppColors.iconLight,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: bookAsync.when(
                    data: (book) => Text(
                      book != null
                          ? 'Chapters: ${book.title}'
                          : 'Quản Lý Chapters',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                    ),
                    loading: () => const Text('Loading...'),
                    error: (_, __) => const Text('Quản Lý Chapters'),
                  ),
                ),
                if (_isSelectionMode && _selectedChapterIds.isNotEmpty)
                  Row(
                    children: [
                      Text(
                        '${_selectedChapterIds.length} đã chọn',
                        style: TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      InteractiveButton(
                        label: 'Hủy',
                        onPressed: () {
                          setState(() {
                            _isSelectionMode = false;
                            _selectedChapterIds.clear();
                          });
                        },
                        isOutlined: true,
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InteractiveButton(
                        label: 'Xóa',
                        icon: Icons.delete,
                        onPressed: () {
                          _showBulkDeleteConfirmation(context, ref, bookId);
                        },
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        iconColor: Colors.white,
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      InteractiveButton(
                        icon: Icons.checklist,
                        onPressed: () {
                          setState(() {
                            _isSelectionMode = true;
                          });
                        },
                        isIconButton: true,
                        iconColor: AppColors.iconLight,
                        tooltip: 'Chọn nhiều',
                      ),
                      const SizedBox(width: 8),
                      InteractiveButton(
                        label: 'Thêm Chapter',
                        icon: Icons.add,
                        onPressed: () {
                          context.push('/admin/edit-chapter?bookId=$bookId');
                        },
                        gradient: AppColors.primaryGradient,
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Chapters list
          Expanded(
            child: chaptersAsync.when(
              data: (chapters) {
                if (chapters.isEmpty) {
                  return EmptyState(
                    title: 'Chưa có chapters nào',
                    message: 'Bắt đầu bằng cách thêm chapter mới',
                    icon: Icons.menu_book_outlined,
                    action: InteractiveButton(
                      label: 'Thêm Chapter',
                      icon: Icons.add,
                      onPressed: () {
                        context.push('/admin/edit-chapter?bookId=$bookId');
                      },
                      gradient: AppColors.primaryGradient,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isSelectionMode)
                              Checkbox(
                                value: _selectedChapterIds.contains(chapter.id),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedChapterIds.add(chapter.id);
                                    } else {
                                      _selectedChapterIds.remove(chapter.id);
                                    }
                                  });
                                },
                              ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${chapter.chapterNumber}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          chapter.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${chapter.content.length} characters • ${chapter.estimatedReadingTimeMinutes ?? 0} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        trailing: _isSelectionMode
                            ? null
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InteractiveButton(
                                    icon: Icons.edit,
                                    onPressed: () {
                                      context.push(
                                        '/admin/edit-chapter?bookId=$bookId&chapterId=${chapter.id}',
                                      );
                                    },
                                    isIconButton: true,
                                    iconColor: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  InteractiveButton(
                                    icon: Icons.delete,
                                    onPressed: () {
                                      _showDeleteConfirmation(
                                        context,
                                        ref,
                                        chapter,
                                        bookId,
                                      );
                                    },
                                    isIconButton: true,
                                    iconColor: Colors.red,
                                  ),
                                ],
                              ),
                        onTap: () {
                          if (_isSelectionMode) {
                            setState(() {
                              if (_selectedChapterIds.contains(chapter.id)) {
                                _selectedChapterIds.remove(chapter.id);
                              } else {
                                _selectedChapterIds.add(chapter.id);
                              }
                            });
                          } else {
                            context.push(
                              '/admin/edit-chapter?bookId=$bookId&chapterId=${chapter.id}',
                            );
                          }
                        },
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
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    InteractiveButton(
                      label: 'Retry',
                      icon: Icons.refresh,
                      onPressed: () {
                        ref.invalidate(bookChaptersProvider(bookId));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBulkDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String bookId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa ${_selectedChapterIds.length} chapters?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _bulkDelete(context, ref, bookId);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _bulkDelete(
    BuildContext context,
    WidgetRef ref,
    String bookId,
  ) async {
    try {
      final repository = ChapterRepository();
      final futures = _selectedChapterIds.map((chapterId) {
        return repository.deleteChapter(chapterId);
      });

      await Future.wait(futures);
      ref.invalidate(bookChaptersProvider(bookId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã xóa ${_selectedChapterIds.length} chapters thành công',
            ),
          ),
        );
        setState(() {
          _isSelectionMode = false;
          _selectedChapterIds.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  void _showDeleteConfirmation(
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
                    const SnackBar(content: Text('Đã xóa chapter thành công')),
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
}
