import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/bookmark_model.dart';

/// Provider for all bookmarks
final allBookmarksProvider = FutureProvider<List<BookmarkModel>>((ref) async {
  final firestore = FirebaseService().firestore;
  
  try {
    Query query = firestore
        .collection(AppConstants.bookmarksCollection)
        .orderBy('createdAt', descending: true)
        .limit(200);
    
    final snapshot = await query.get();
    
    List<BookmarkModel> bookmarks = snapshot.docs
        .map((doc) {
          try {
            return BookmarkModel.fromFirestore(doc);
          } catch (e) {
            return null;
          }
        })
        .where((bookmark) => bookmark != null)
        .cast<BookmarkModel>()
        .toList();
    
    bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return bookmarks.take(100).toList();
  } catch (e) {
    final snapshot = await firestore
        .collection(AppConstants.bookmarksCollection)
        .limit(200)
        .get();
    
    List<BookmarkModel> bookmarks = snapshot.docs
        .map((doc) {
          try {
            return BookmarkModel.fromFirestore(doc);
          } catch (e) {
            return null;
          }
        })
        .where((bookmark) => bookmark != null)
        .cast<BookmarkModel>()
        .toList();
    
    bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return bookmarks.take(100).toList();
  }
});

/// Trang quản lý bookmarks
class ManageBookmarksPage extends ConsumerStatefulWidget {
  const ManageBookmarksPage({super.key});

  @override
  ConsumerState<ManageBookmarksPage> createState() => _ManageBookmarksPageState();
}

class _ManageBookmarksPageState extends ConsumerState<ManageBookmarksPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveUtils.isMobile(context);
        final padding = ResponsiveUtils.pagePadding(context);
        final bookmarksAsync = ref.watch(allBookmarksProvider);

        return Column(
          children: [
            // Header
            Container(
              color: Theme.of(context).cardColor,
              padding: EdgeInsets.all(padding),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quản Lý Bookmarks',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm...',
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
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quản Lý Bookmarks',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        SizedBox(
                          width: 250,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm...',
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
                      ],
                    ),
            ),
            // Content
            Expanded(
              child: bookmarksAsync.when(
                data: (bookmarks) {
                  // Filter bookmarks
                  var filteredBookmarks = bookmarks.where((bookmark) {
                    if (_searchQuery.isNotEmpty) {
                      final query = _searchQuery.toLowerCase();
                      final noteMatch = bookmark.note?.toLowerCase().contains(query) ?? false;
                      final highlightMatch = bookmark.highlightedText?.toLowerCase().contains(query) ?? false;
                      return noteMatch || highlightMatch;
                    }
                    return true;
                  }).toList();

                  if (filteredBookmarks.isEmpty) {
                    return const EmptyState(
                      title: 'Không có dữ liệu',
                      message: 'Không có bookmark nào',
                      icon: Icons.bookmark_border,
                    );
                  }

                  return isMobile
                      ? _buildMobileList(filteredBookmarks)
                      : _buildDesktopList(filteredBookmarks);
                },
                loading: () => const Center(
                  child: ShimmerLoading(
                    width: double.infinity,
                    height: 200,
                  ),
                ),
                error: (error, stack) => ErrorState(
                  title: 'Lỗi',
                  message: 'Lỗi khi tải bookmarks: $error',
                  onRetry: () => ref.invalidate(allBookmarksProvider),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileList(List<BookmarkModel> bookmarks) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return _buildMobileBookmarkCard(bookmark);
      },
    );
  }

  Widget _buildDesktopList(List<BookmarkModel> bookmarks) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return _buildDesktopBookmarkCard(bookmark);
      },
    );
  }

  Widget _buildMobileBookmarkCard(BookmarkModel bookmark) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showBookmarkActions(bookmark),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bookmark, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Chapter ${bookmark.chapterNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(bookmark.createdAt),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (bookmark.highlightedText != null && bookmark.highlightedText!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bookmark.highlightedText!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (bookmark.note != null && bookmark.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  bookmark.note!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    'User: ${bookmark.userId.substring(0, 8)}...',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.book, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    'Book: ${bookmark.bookId.substring(0, 8)}...',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopBookmarkCard(BookmarkModel bookmark) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showBookmarkActions(bookmark),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.bookmark, color: Colors.amber, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chapter ${bookmark.chapterNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (bookmark.highlightedText != null && bookmark.highlightedText!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bookmark.highlightedText!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (bookmark.note != null && bookmark.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        bookmark.note!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          'User: ${bookmark.userId.substring(0, 8)}...',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.book, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          'Book: ${bookmark.bookId.substring(0, 8)}...',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _formatDate(bookmark.createdAt),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () => _showBookmarkActions(bookmark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookmarkActions(BookmarkModel bookmark) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa bookmark'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(bookmark);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Đóng'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BookmarkModel bookmark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bookmark này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteBookmark(bookmark.id);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBookmark(String bookmarkId) async {
    try {
      final firestore = FirebaseService().firestore;
      await firestore
          .collection(AppConstants.bookmarksCollection)
          .doc(bookmarkId)
          .delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa bookmark')),
        );
        ref.invalidate(allBookmarksProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
