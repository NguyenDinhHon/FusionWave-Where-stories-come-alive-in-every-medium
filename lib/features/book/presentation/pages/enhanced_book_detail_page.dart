import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../../social/presentation/providers/social_provider.dart';
import '../../../bookmark/presentation/providers/bookmark_provider.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/share_service.dart';
import '../../../../data/models/book_model.dart';
import '../../../offline/presentation/widgets/offline_indicator.dart';
import '../../../offline/presentation/pages/offline_books_page.dart';

/// Enhanced BookDetailPage with parallax header and animations
class EnhancedBookDetailPage extends ConsumerStatefulWidget {
  final String bookId;
  
  const EnhancedBookDetailPage({
    super.key,
    required this.bookId,
  });

  @override
  ConsumerState<EnhancedBookDetailPage> createState() => _EnhancedBookDetailPageState();
}

class _EnhancedBookDetailPageState extends ConsumerState<EnhancedBookDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = false;
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookByIdProvider(widget.bookId));
    final libraryItemAsync = ref.watch(libraryItemByBookIdProvider(widget.bookId));
    final userRatingAsync = ref.watch(userRatingProvider(widget.bookId));
    final averageRatingAsync = ref.watch(bookAverageRatingProvider(widget.bookId));
    final bookmarksAsync = ref.watch(bookmarksByBookIdProvider(widget.bookId));
    
    return Scaffold(
      body: Column(
        children: [
          // Offline indicator
          const OfflineIndicator(),
          Expanded(
            child: bookAsync.when(
        data: (book) {
          if (book == null) {
            return const Center(child: Text('Book not found'));
          }
          
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Parallax AppBar với cover image
              SliverAppBar(
                expandedHeight: 400,
                floating: false,
                pinned: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    book.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (book.coverImageUrl != null)
                        Image.network(
                          book.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderCover(),
                        )
                      else
                        _buildPlaceholderCover(),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Consumer(
                    builder: (context, ref, _) {
                      final offlineServiceAsync = ref.watch(offlineServiceProvider);
                      return offlineServiceAsync.when(
                        data: (offlineService) {
                          final isDownloaded = offlineService.isBookDownloaded(book.id);
                          return IconButton(
                            icon: Icon(
                              isDownloaded ? Icons.cloud_done : Icons.cloud_download,
                              color: Colors.white,
                            ),
                            tooltip: isDownloaded ? 'Remove from offline' : 'Download for offline',
                            onPressed: () async {
                              if (isDownloaded) {
                                await offlineService.removeDownloadedBook(book.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Removed from offline')),
                                  );
                                }
                              } else {
                                await offlineService.downloadBook(book.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Book downloaded for offline reading'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () async {
                      final shareService = ShareService();
                      await shareService.shareBook(book);
                    },
                  ),
                ],
              ),
              
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Authors
                      if (book.authors.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.person, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                book.authors.join(', '),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Stats Cards
                      _buildStatsCards(context, book, averageRatingAsync),
                      const SizedBox(height: 24),
                      
                      // Rating Section với animations
                      _buildAnimatedRatingSection(
                        context,
                        ref,
                        userRatingAsync,
                        averageRatingAsync,
                      ),
                      const SizedBox(height: 24),
                      
                      // Description với expand/collapse
                      _buildExpandableDescription(context, book),
                      const SizedBox(height: 24),
                      
                      // Bookmarks count
                      bookmarksAsync.when(
                        data: (bookmarks) {
                          if (bookmarks.isNotEmpty) {
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () => context.push('/bookmarks?bookId=${book.id}'),
                                  child: Card(
                                    color: AppColors.bookmarkColor.withOpacity(0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.bookmark,
                                            color: AppColors.bookmarkColor,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${bookmarks.length} Bookmark${bookmarks.length > 1 ? 's' : ''}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.bookmarkColor,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(Icons.chevron_right),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          }
                          return const SizedBox();
                        },
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                      
                      // Action Buttons
                      _buildActionButtons(
                        context,
                        ref,
                        book,
                        libraryItemAsync,
                      ),
                      const SizedBox(height: 24),
                      
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
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(bookByIdProvider(widget.bookId)),
        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.book, size: 100, color: Colors.grey),
      ),
    );
  }

  Widget _buildStatsCards(
    BuildContext context,
    BookModel book,
    AsyncValue<double?> averageRatingAsync,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            Icons.menu_book,
            '${book.totalChapters}',
            'Chapters',
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            Icons.book,
            '${book.totalPages}',
            'Pages',
            AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: averageRatingAsync.when(
            data: (rating) => _buildStatCard(
              context,
              Icons.star,
              rating?.toStringAsFixed(1) ?? 'N/A',
              'Rating',
              Colors.amber,
            ),
            loading: () => const ShimmerLoading(
              width: double.infinity,
              height: 80,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedRatingSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> userRatingAsync,
    AsyncValue<double?> averageRatingAsync,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rate this book',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                averageRatingAsync.when(
                  data: (rating) => rating != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return userRatingAsync.when(
                  data: (rating) {
                    final userRating = rating;
                    final userRatingValue = userRating?.rating as int?;
                    final isSelected = userRatingValue != null && index < userRatingValue;
                    
                    return GestureDetector(
                      onTap: () async {
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isSelected ? Icons.star : Icons.star_border,
                          color: isSelected ? Colors.amber : Colors.grey,
                          size: 40,
                        ),
                      ),
                    );
                  },
                  loading: () => const Icon(Icons.star_border, size: 40),
                  error: (_, __) => const Icon(Icons.star_border, size: 40),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableDescription(BuildContext context, BookModel book) {
    if (book.description == null) return const SizedBox();
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              book.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    BookModel book,
    AsyncValue<dynamic> libraryItemAsync,
  ) {
    return libraryItemAsync.when(
      data: (libraryItem) {
        if (libraryItem != null) {
          return Column(
            children: [
              AnimatedButton(
                text: 'Continue Reading',
                icon: Icons.play_arrow,
                width: double.infinity,
                onPressed: () {
                  context.push('/reading/${book.id}?chapterId=${libraryItem.currentChapter}');
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final controller = ref.read(libraryControllerProvider);
                  await controller.removeFromLibrary(book.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Removed from library'),
                        backgroundColor: Colors.green,
                      ),
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
          return AnimatedButton(
            text: 'Add to Library',
            icon: Icons.add,
            width: double.infinity,
            onPressed: () async {
              final controller = ref.read(libraryControllerProvider);
              await controller.addToLibrary(book.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to library'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => AnimatedButton(
        text: 'Add to Library',
        icon: Icons.add,
        width: double.infinity,
        onPressed: () async {
          final controller = ref.read(libraryControllerProvider);
          await controller.addToLibrary(book.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Added to library'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }
}

