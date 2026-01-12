import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../providers/bookmark_provider.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../data/models/bookmark_model.dart';

/// Bookmarks list page
class BookmarksPage extends ConsumerWidget {
  final String? bookId;
  
  const BookmarksPage({
    super.key,
    this.bookId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = bookId != null
        ? ref.watch(bookmarksByBookIdProvider(bookId!))
        : ref.watch(userBookmarksProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(bookId != null ? 'Book Bookmarks' : 'My Bookmarks'),
        actions: [
          if (bookId != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng thêm bookmark từ trang đọc sách'),
                  ),
                );
              },
            ),
        ],
      ),
      body: bookmarksAsync.when(
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return EmptyState(
              title: 'No bookmarks yet',
              message: bookId != null
                  ? 'Add bookmarks while reading to see them here'
                  : 'Start reading and add bookmarks to save your favorite passages',
              icon: Icons.bookmark_border,
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              return _buildBookmarkCard(context, ref, bookmark);
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
          onRetry: () => ref.invalidate(
            bookId != null
                ? bookmarksByBookIdProvider(bookId!)
                : userBookmarksProvider,
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkCard(
    BuildContext context,
    WidgetRef ref,
    BookmarkModel bookmark,
  ) {
    final bookAsync = ref.watch(bookByIdProvider(bookmark.bookId));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/reading/${bookmark.bookId}?chapterId=${bookmark.chapterId}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: bookAsync.when(
                      data: (book) => Text(
                        book?.title ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      loading: () => const Text('Loading...'),
                      error: (_, _) => const Text('Unknown Book'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _showDeleteDialog(context, ref, bookmark),
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.bookmark, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    'Chapter ${bookmark.chapterNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (bookmark.pageNumber != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Page ${bookmark.pageNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              if (bookmark.highlightedText != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bookmark.highlightedText!,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (bookmark.note != null) ...[
                const SizedBox(height: 8),
                Text(
                  bookmark.note!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                _formatDate(bookmark.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    BookmarkModel bookmark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bookmark'),
        content: const Text('Are you sure you want to delete this bookmark?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(bookmarkControllerProvider).deleteBookmark(bookmark.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bookmark deleted')),
    );
  }
},
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

