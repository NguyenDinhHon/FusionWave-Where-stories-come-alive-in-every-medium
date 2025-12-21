import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../data/models/library_item_model.dart';

/// Reading History page với timeline
class ReadingHistoryPage extends ConsumerWidget {
  const ReadingHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedBooksAsync = ref.watch(
      libraryItemsProvider('completed'),
    );
    final readingBooksAsync = ref.watch(
      libraryItemsProvider('reading'),
    );
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reading History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All', icon: Icon(Icons.history)),
              Tab(text: 'Reading', icon: Icon(Icons.menu_book)),
              Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAllHistory(context, ref, readingBooksAsync, completedBooksAsync),
            _buildReadingHistory(context, ref, readingBooksAsync),
            _buildCompletedHistory(context, ref, completedBooksAsync),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAllHistory(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<LibraryItemModel>> readingAsync,
    AsyncValue<List<LibraryItemModel>> completedAsync,
  ) {
    return readingAsync.when(
      data: (readingBooks) {
        return completedAsync.when(
          data: (completedBooks) {
            final allBooks = [
              ...readingBooks.map((item) => _HistoryItem(item, 'reading')),
              ...completedBooks.map((item) => _HistoryItem(item, 'completed')),
            ];
            
            // Sort by lastReadAt descending
            allBooks.sort((a, b) {
              final dateA = a.item.lastReadAt ?? a.item.addedAt;
              final dateB = b.item.lastReadAt ?? b.item.addedAt;
              return dateB.compareTo(dateA);
            });
            
            if (allBooks.isEmpty) {
              return EmptyState(
                title: 'No reading history',
                message: 'Start reading books to see your history here',
                icon: Icons.history,
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allBooks.length,
              itemBuilder: (context, index) {
                final historyItem = allBooks[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildHistoryCard(context, ref, historyItem.item, historyItem.status),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(libraryItemsProvider('completed')),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(libraryItemsProvider('reading')),
      ),
    );
  }
  
  Widget _buildReadingHistory(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<LibraryItemModel>> readingAsync,
  ) {
    return readingAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return EmptyState(
            title: 'No books being read',
            message: 'Start reading a book to see it here',
            icon: Icons.menu_book,
          );
        }
        
        // Sort by lastReadAt descending
        final sortedBooks = List<LibraryItemModel>.from(books);
        sortedBooks.sort((a, b) {
          final dateA = a.lastReadAt ?? a.addedAt;
          final dateB = b.lastReadAt ?? b.addedAt;
          return dateB.compareTo(dateA);
        });
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedBooks.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildHistoryCard(context, ref, sortedBooks[index], 'reading'),
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
        onRetry: () => ref.invalidate(libraryItemsProvider('reading')),
      ),
    );
  }
  
  Widget _buildCompletedHistory(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<LibraryItemModel>> completedAsync,
  ) {
    return completedAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return EmptyState(
            title: 'No completed books',
            message: 'Complete reading a book to see it here',
            icon: Icons.check_circle,
          );
        }
        
        // Sort by lastReadAt descending
        final sortedBooks = List<LibraryItemModel>.from(books);
        sortedBooks.sort((a, b) {
          final dateA = a.lastReadAt ?? a.addedAt;
          final dateB = b.lastReadAt ?? b.addedAt;
          return dateB.compareTo(dateA);
        });
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedBooks.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildHistoryCard(context, ref, sortedBooks[index], 'completed'),
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
        onRetry: () => ref.invalidate(libraryItemsProvider('completed')),
      ),
    );
  }
  
  Widget _buildHistoryCard(
    BuildContext context,
    WidgetRef ref,
    LibraryItemModel item,
    String status,
  ) {
    final bookAsync = ref.watch(bookByIdProvider(item.bookId));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/book/${item.bookId}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                child: bookAsync.when(
                  data: (book) => book?.coverImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            book!.coverImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.book),
                          ),
                        )
                      : const Icon(Icons.book),
                  loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (_, __) => const Icon(Icons.book),
                ),
              ),
              const SizedBox(width: 16),
              
              // Book info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bookAsync.when(
                      data: (book) => Text(
                        book?.title ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      loading: () => const Text('Loading...'),
                      error: (_, __) => const Text('Unknown Book'),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: status == 'completed' 
                                ? Colors.green.withOpacity(0.2)
                                : Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status == 'completed' ? 'Completed' : 'Reading',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: status == 'completed' 
                                  ? Colors.green[700]
                                  : Colors.blue[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (item.progress > 0)
                          Text(
                            '${(item.progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.menu_book, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Chapter ${item.currentChapter}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatLastRead(item.lastReadAt ?? item.addedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatLastRead(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _HistoryItem {
  final LibraryItemModel item;
  final String status;
  
  _HistoryItem(this.item, this.status);
}

