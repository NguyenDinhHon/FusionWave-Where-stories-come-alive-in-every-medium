import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
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
  
  try {
    // Try with orderBy first
    Query query = firestore
        .collection(AppConstants.commentsCollection)
        .orderBy('createdAt', descending: true)
        .limit(200); // Get more to sort in memory if needed
    
    final snapshot = await query.get();
    
    List<CommentModel> comments = snapshot.docs
        .map((doc) {
          try {
            return CommentModel.fromFirestore(doc);
          } catch (e) {
            return null;
          }
        })
        .where((comment) => comment != null)
        .cast<CommentModel>()
        .toList();
    
    // Sort by createdAt descending if not already sorted
    comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return comments.take(100).toList();
  } catch (e) {
    // If orderBy fails (missing index), get all and sort in memory
    final snapshot = await firestore
        .collection(AppConstants.commentsCollection)
        .limit(200)
        .get();
    
    List<CommentModel> comments = snapshot.docs
        .map((doc) {
          try {
            return CommentModel.fromFirestore(doc);
          } catch (e) {
            return null;
          }
        })
        .where((comment) => comment != null)
        .cast<CommentModel>()
        .toList();
    
    // Sort by createdAt descending
    comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return comments.take(100).toList();
  }
});

/// Trang quản lý comments - Mobile optimized
class ManageCommentsPage extends ConsumerStatefulWidget {
  const ManageCommentsPage({super.key});

  @override
  ConsumerState<ManageCommentsPage> createState() =>
      _ManageCommentsPageState();
}

class _ManageCommentsPageState extends ConsumerState<ManageCommentsPage> {
  String _searchQuery = '';
  bool _showOnlyTopLevel = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveUtils.isMobile(context);
        final padding = ResponsiveUtils.pagePadding(context);
        final commentsAsync = ref.watch(allCommentsProvider);

        return Column(
          children: [
            // Header - Responsive
            Container(
              color: Theme.of(context).cardColor,
              padding: EdgeInsets.all(padding),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quản Lý Comments',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // White text
                              ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm nội dung...',
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
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          title: const Text('Chỉ hiển thị comment gốc'),
                          value: _showOnlyTopLevel,
                          onChanged: (value) {
                            setState(() {
                              _showOnlyTopLevel = value ?? false;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quản Lý Comments',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // White text
                              ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 250,
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
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 150,
                          child: CheckboxListTile(
                            title: const Text(
                              'Top Level Only',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: _showOnlyTopLevel,
                            onChanged: (value) {
                              setState(() {
                                _showOnlyTopLevel = value ?? false;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
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

                  if (filteredComments.isEmpty) {
                    return EmptyState(
                      title: 'Không tìm thấy comments',
                      message: _searchQuery.isNotEmpty || _showOnlyTopLevel
                          ? 'Thử thay đổi bộ lọc'
                          : 'Chưa có comments nào',
                      icon: Icons.comment_outlined,
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(padding),
                    itemCount: filteredComments.length,
                    itemBuilder: (context, index) {
                      final comment = filteredComments[index];
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: isMobile
                            ? _buildMobileCommentCard(comment)
                            : _buildDesktopCommentCard(comment),
                      );
                    },
                  );
                },
                loading: () => ListView.builder(
                  padding: EdgeInsets.all(padding),
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error: $error'),
                      ),
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
      },
    );
  }

  Widget _buildMobileCommentCard(CommentModel comment) {
    return InkWell(
      onTap: () => _showCommentDetails(context, ref, comment),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  child: Text(
                    comment.content.isNotEmpty
                        ? comment.content[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.content,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Book: ${comment.bookId.substring(0, comment.bookId.length > 20 ? 20 : comment.bookId.length)}...',
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
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.favorite, size: 14, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  '${comment.likes}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 14,
                    color: AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Text(
                  _formatDate(comment.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopCommentCard(CommentModel comment) {
    return ListTile(
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
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.favorite, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Text('${comment.likes}'),
              const SizedBox(width: 16),
              Text(
                _formatDate(comment.createdAt),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _showDeleteConfirmation(context, ref, comment),
        tooltip: 'Delete Comment',
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  void _showCommentDetails(
    BuildContext context,
    WidgetRef ref,
    CommentModel comment,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chi tiết Comment',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Nội dung:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(comment.content),
              const SizedBox(height: 16),
              _buildDetailRow('Book ID', comment.bookId),
              if (comment.chapterId != null)
                _buildDetailRow('Chapter ID', comment.chapterId!),
              _buildDetailRow('Likes', '${comment.likes}'),
              _buildDetailRow('Ngày tạo', _formatDate(comment.createdAt)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: InteractiveButton(
                  label: 'Xóa Comment',
                  icon: Icons.delete,
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, ref, comment);
                  },
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  iconColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
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
        content: const Text('Bạn có chắc muốn xóa comment này?'),
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
}
