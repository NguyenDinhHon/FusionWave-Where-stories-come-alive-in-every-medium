import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../../social/presentation/providers/social_provider.dart';

class BookDetailPage extends ConsumerStatefulWidget {
  final String bookId;
  
  const BookDetailPage({
    super.key,
    required this.bookId,
  });

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showStickyButton = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    // Show button when scrolled past 300px (after description section)
    final shouldShow = _scrollController.offset > 300;
    if (shouldShow != _showStickyButton) {
      setState(() {
        _showStickyButton = shouldShow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookByIdProvider(widget.bookId));
    final libraryItemAsync = ref.watch(libraryItemByBookIdProvider(widget.bookId));
    final userRatingAsync = ref.watch(userRatingProvider(widget.bookId));
    final averageRatingAsync = ref.watch(bookAverageRatingProvider(widget.bookId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: bookAsync.when(
        data: (book) {
          if (book == null) {
            return const Center(child: Text('Book not found'));
          }
          
          return Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover image
                if (book.coverImageUrl != null)
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(book.coverImageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        book.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Authors
                      if (book.authors.isNotEmpty)
                        Text(
                          book.authors.join(', '),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 16),
                      
                      // Description
                      if (book.description != null) ...[
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Stats
                      Row(
                        children: [
                          _buildStatItem(context, 'Pages', book.totalPages.toString()),
                          const SizedBox(width: 24),
                          _buildStatItem(context, 'Chapters', book.totalChapters.toString()),
                          const SizedBox(width: 24),
                          averageRatingAsync.when(
                            data: (rating) => _buildStatItem(
                              context,
                              'Rating',
                              rating?.toStringAsFixed(1) ?? 'N/A',
                            ),
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Rating section
                      _buildRatingSection(context, ref, userRatingAsync, averageRatingAsync),
                      const SizedBox(height: 16),
                      
                      // Comments button
                      OutlinedButton.icon(
                        onPressed: () {
                          context.push('/book/${book.id}/comments');
                        },
                        icon: const Icon(Icons.comment),
                        label: const Text('View Comments'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Action buttons
                      libraryItemAsync.when(
                        data: (libraryItem) {
                          if (libraryItem != null) {
                            return Column(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.push('/reading/${book.id}?chapterId=${libraryItem.currentChapter}');
                                  },
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Continue Reading'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 48),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final controller = ref.read(libraryControllerProvider);
                                    await controller.removeFromLibrary(book.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Removed from library')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Remove from Library'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 48),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return ElevatedButton.icon(
                              onPressed: () async {
                                final controller = ref.read(libraryControllerProvider);
                                await controller.addToLibrary(book.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Added to library')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add to Library'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            );
                          }
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => ElevatedButton.icon(
                          onPressed: () async {
                            final controller = ref.read(libraryControllerProvider);
                            await controller.addToLibrary(book.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to library')),
                              );
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add to Library'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
              
              // Sticky Read Now button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  offset: _showStickyButton ? Offset.zero : const Offset(0, 1),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showStickyButton ? 1.0 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: SafeArea(
                        top: false,
                        child: libraryItemAsync.when(
                          data: (libraryItem) {
                            if (libraryItem != null) {
                              return ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/reading/${book.id}?chapterId=${libraryItem.currentChapter}');
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Continue Reading'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            } else {
                              return ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/reading/${book.id}');
                                },
                                icon: const Icon(Icons.menu_book),
                                label: const Text('Start Reading'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          },
                          loading: () => ElevatedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.menu_book),
                            label: const Text('Start Reading'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          error: (_, __) => ElevatedButton.icon(
                            onPressed: () {
                              context.push('/reading/${book.id}');
                            },
                            icon: const Icon(Icons.menu_book),
                            label: const Text('Start Reading'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> userRatingAsync,
    AsyncValue<double?> averageRatingAsync,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rate this book',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                averageRatingAsync.when(
                  data: (rating) => rating != null
                      ? Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : const SizedBox(),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return userRatingAsync.when(
                  data: (rating) {
                    final userRating = rating;
                    final userRatingValue = userRating?.rating as int?;
                    final isSelected = userRatingValue != null && index < userRatingValue;
                    
                    return IconButton(
                      icon: Icon(
                        isSelected ? Icons.star : Icons.star_border,
                        color: isSelected ? Colors.amber : Colors.grey,
                        size: 32,
                      ),
                      onPressed: () async {
                        try {
                          await ref.read(socialControllerProvider).rateBook(
                            bookId: widget.bookId,
                            rating: index + 1,
                          );
                          ref.invalidate(userRatingProvider(widget.bookId));
                          ref.invalidate(bookAverageRatingProvider(widget.bookId));
                          ref.invalidate(bookByIdProvider(widget.bookId));
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    );
                  },
                  loading: () => IconButton(
                    icon: const Icon(Icons.star_border, size: 32),
                    onPressed: () {},
                  ),
                  error: (_, __) => IconButton(
                    icon: const Icon(Icons.star_border, size: 32),
                    onPressed: () {},
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

