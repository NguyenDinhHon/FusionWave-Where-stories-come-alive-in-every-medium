import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/collection_provider.dart';
import '../../../../../features/home/presentation/providers/book_provider.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/shimmer_loading.dart';
import '../../../../../data/models/collection_model.dart';

/// Collection detail page
class CollectionDetailPage extends ConsumerWidget {
  final String collectionId;
  
  const CollectionDetailPage({
    super.key,
    required this.collectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(collectionByIdProvider(collectionId));
    
    return Scaffold(
      appBar: AppBar(
        title: collectionAsync.when(
          data: (collection) => Text(collection?.name ?? 'Collection'),
          loading: () => const Text('Collection'),
          error: (_, __) => const Text('Collection'),
        ),
        actions: [
          collectionAsync.when(
            data: (collection) {
              if (collection == null) return const SizedBox();
              return PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                    onTap: () {
                      // TODO: Show edit dialog
                    },
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    onTap: () async {
                      await ref.read(collectionControllerProvider).deleteCollection(collectionId);
                      if (context.mounted) {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Collection deleted')),
                        );
                      }
                    },
                  ),
                ],
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: collectionAsync.when(
        data: (collection) {
          if (collection == null) {
            return const Center(child: Text('Collection not found'));
          }
          
          if (collection.bookIds.isEmpty) {
            return EmptyState(
              title: 'No books in collection',
              message: 'Add books to this collection to see them here',
              icon: Icons.book_outlined,
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: collection.bookIds.length,
            itemBuilder: (context, index) {
              final bookId = collection.bookIds[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildBookItem(context, ref, bookId, collection),
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
          onRetry: () => ref.invalidate(collectionByIdProvider(collectionId)),
        ),
      ),
    );
  }
  
  Widget _buildBookItem(
    BuildContext context,
    WidgetRef ref,
    String bookId,
    CollectionModel collection,
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
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () async {
                await ref.read(collectionControllerProvider).removeBookFromCollection(
                  collectionId: collection.id,
                  bookId: bookId,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Book removed from collection')),
                  );
                }
              },
            ),
            onTap: () => context.push('/book/$bookId'),
          ),
        );
      },
      loading: () => const ShimmerListItem(),
      error: (_, __) => const SizedBox(),
    );
  }
}

