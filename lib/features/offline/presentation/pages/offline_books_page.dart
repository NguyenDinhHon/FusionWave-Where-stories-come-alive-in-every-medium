import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../../../../core/services/offline_service.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';

/// Offline Books page
class OfflineBooksPage extends ConsumerWidget {
  const OfflineBooksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineServiceAsync = ref.watch(offlineServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Books'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearAllDialog(context, ref),
          ),
        ],
      ),
      body: offlineServiceAsync.when(
        data: (offlineService) {
          final downloadedBooks = offlineService.getDownloadedBooks();
          
          if (downloadedBooks.isEmpty) {
            return EmptyState(
              title: 'No offline books',
              message: 'Download books to read them offline',
              icon: Icons.cloud_download_outlined,
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: downloadedBooks.length,
            itemBuilder: (context, index) {
              final bookId = downloadedBooks[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildOfflineBookCard(context, ref, bookId, offlineService),
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
          onRetry: () => ref.invalidate(offlineServiceProvider),
        ),
      ),
    );
  }
  
  Widget _buildOfflineBookCard(
    BuildContext context,
    WidgetRef ref,
    String bookId,
    OfflineService offlineService,
  ) {
    final bookAsync = ref.watch(bookByIdProvider(bookId));
    
    return bookAsync.when(
      data: (book) {
        if (book == null) return const SizedBox();
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 70,
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
                        errorBuilder: (_, __, ___) => const Icon(Icons.book),
                      ),
                    )
                  : const Icon(Icons.book),
            ),
            title: Text(
              book.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: book.authors.isNotEmpty
                ? Text(book.authors.join(', '))
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_done,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showRemoveDialog(context, ref, bookId, book.title),
                ),
              ],
            ),
            onTap: () => context.push('/book/$bookId'),
          ),
        );
      },
      loading: () => const ShimmerListItem(),
      error: (_, __) => const SizedBox(),
    );
  }
  
  void _showRemoveDialog(
    BuildContext context,
    WidgetRef ref,
    String bookId,
    String bookTitle,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Offline Book'),
        content: Text('Remove "$bookTitle" from offline storage?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final offlineServiceAsync = ref.read(offlineServiceProvider);
              offlineServiceAsync.whenData((service) async {
                await service.removeDownloadedBook(bookId);
              });
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Book removed from offline')),
                );
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Offline Content'),
        content: const Text('Remove all downloaded books? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final offlineServiceAsync = ref.read(offlineServiceProvider);
              offlineServiceAsync.whenData((service) async {
                await service.clearAllOfflineContent();
              });
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All offline content cleared')),
                );
              }
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Offline service provider
final offlineServiceProvider = FutureProvider<OfflineService>((ref) async {
  final service = OfflineService();
  await service.init();
  return service;
});

