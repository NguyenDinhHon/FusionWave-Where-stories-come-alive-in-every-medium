import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/comment_model.dart';

/// Provider for all comments
final allCommentsProvider = FutureProvider<List<CommentModel>>((ref) async {
  final firestore = FirebaseService().firestore;
  final snapshot = await firestore
      .collection(AppConstants.commentsCollection)
      .orderBy('createdAt', descending: true)
      .limit(100)
      .get();

  return snapshot.docs
      .map((doc) => CommentModel.fromFirestore(doc))
      .toList();
});

/// Trang quản lý comments
class ManageCommentsPage extends ConsumerStatefulWidget {
  const ManageCommentsPage({super.key});

  @override
  ConsumerState<ManageCommentsPage> createState() =>
      _ManageCommentsPageState();
}

class _ManageCommentsPageState extends ConsumerState<ManageCommentsPage> {
  String _searchQuery = '';
  String? _bookIdFilter;
  bool _showOnlyTopLevel = true;

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(allCommentsProvider);

    return Column(
        children: [
          // Header
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quản Lý Comments',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Checkbox(
                      value: _showOnlyTopLevel,
                      onChanged: (value) {
                        setState(() {
                          _showOnlyTopLevel = value ?? true;
                        });
                      },
                    ),
                    const Text('Top Level Only'),
                  ],
                ),
              ],
            ),
          ),
          // Comments list
          Expanded(
            child: commentsAsync.when(
              data: (comments) {
                var filteredComments = comments;
                if (_showOnlyTopLevel) {
                  filteredComments = filteredComments
                      .where((c) => c.parentCommentId == null)
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  filteredComments = filteredComments
                      .where((c) =>
                          c.content.toLowerCase().contains(query) ||
                          c.bookId.toLowerCase().contains(query))
                      .toList();
                }
                if (_bookIdFilter != null && _bookIdFilter!.isNotEmpty) {
                  filteredComments = filteredComments
                      .where((c) => c.bookId == _bookIdFilter)
                      .toList();
                }

                if (filteredComments.isEmpty) {
                  return EmptyState(
                    title: 'Không tìm thấy comments',
                    message: _searchQuery.isNotEmpty || _bookIdFilter != null
                        ? 'Thử thay đổi bộ lọc'
                        : 'Chưa có comments nào',
                    icon: Icons.comment_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredComments.length,
                  itemBuilder: (context, index) {
                    final comment = filteredComments[index];
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            comment.content.isNotEmpty
                                ? comment.content[0].toUpperCase()
                                : 'C',
                          ),
                        ),
                        title: Text(
                          comment.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Book ID: ${comment.bookId}'),
                            if (comment.chapterId != null)
                              Text('Chapter ID: ${comment.chapterId}'),
                            Text(
                              'Created: ${comment.createdAt.toString().split('.')[0]}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Row(
                              children: [
                                Icon(Icons.favorite,
                                    size: 16, color: Colors.red),
                                const SizedBox(width: 4),
                                Text('${comment.likes}'),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InteractiveButton(
                              icon: Icons.delete,
                              onPressed: () {
                                _showDeleteConfirmation(context, ref, comment);
                              },
                              isIconButton: true,
                              iconColor: Colors.red,
                            ),
                          ],
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
                      onPressed: () => ref.invalidate(allCommentsProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    CommentModel comment,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa comment này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final firestore = FirebaseService().firestore;
                await firestore
                    .collection(AppConstants.commentsCollection)
                    .doc(comment.id)
                    .delete();
                ref.invalidate(allCommentsProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa comment thành công'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
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
}
