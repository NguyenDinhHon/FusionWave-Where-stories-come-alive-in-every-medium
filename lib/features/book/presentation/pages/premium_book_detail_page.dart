import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../../social/presentation/providers/social_provider.dart';
import '../../../reading/presentation/providers/reading_provider.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/share_service.dart';
import '../../../../data/models/book_model.dart';
import '../../../offline/presentation/widgets/offline_indicator.dart';
import '../../../offline/presentation/pages/offline_books_page.dart';
import '../../../recommendations/presentation/providers/recommendation_provider.dart';

/// Premium BookDetailPage với design giống Wattpad & Waka
class PremiumBookDetailPage extends ConsumerStatefulWidget {
  final String bookId;
  
  const PremiumBookDetailPage({
    super.key,
    required this.bookId,
  });

  @override
  ConsumerState<PremiumBookDetailPage> createState() => _PremiumBookDetailPageState();
}

class _PremiumBookDetailPageState extends ConsumerState<PremiumBookDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isDescriptionExpanded = false;
  
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
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: bookAsync.when(
              data: (book) {
                if (book == null) {
                  return const Center(
                    child: Text(
                      'Book not found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                
                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Premium Parallax Header
                    _buildPremiumHeader(context, book),
                    
                    // Book Info Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title & Authors
                            _buildTitleSection(context, book),
                            const SizedBox(height: 20),
                            
                            // Action Buttons
                            _buildActionButtons(context, ref, book, libraryItemAsync),
                            const SizedBox(height: 24),
                            
                            // Stats Cards
                            _buildStatsCards(context, ref, book, averageRatingAsync),
                            const SizedBox(height: 24),
                            
                            // Rating Section
                            _buildRatingSection(context, ref, book, userRatingAsync, averageRatingAsync),
                            const SizedBox(height: 24),
                            
                            // Description
                            _buildDescriptionSection(context, book),
                            const SizedBox(height: 24),
                            
                            // Categories
                            if (book.categories.isNotEmpty) ...[
                              _buildCategoriesSection(context, book),
                              const SizedBox(height: 24),
                            ],
                            
                            // Chapters List
                            _buildChaptersSection(context, ref, book),
                            const SizedBox(height: 24),
                            
                            // Reviews Section
                            _buildReviewsSection(context, ref, book),
                            const SizedBox(height: 24),
                            
                            // Similar Books
                            _buildSimilarBooksSection(context, ref, book),
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
  
  Widget _buildPremiumHeader(BuildContext context, BookModel book) {
    return SliverAppBar(
      expandedHeight: 450,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: InteractiveIconButton(
        icon: Icons.arrow_back,
        iconColor: Colors.white,
        size: 32,
        onPressed: () => context.pop(),
        tooltip: 'Back',
      ),
      actions: [
        Consumer(
          builder: (context, ref, _) {
            final offlineServiceAsync = ref.watch(offlineServiceProvider);
            return offlineServiceAsync.when(
              data: (offlineService) {
                final isDownloaded = offlineService.isBookDownloaded(book.id);
                return InteractiveIconButton(
                  icon: isDownloaded ? Icons.cloud_done : Icons.cloud_download,
                  iconColor: Colors.white,
                  size: 32,
                  onPressed: () async {
                    if (isDownloaded) {
                      await offlineService.removeDownloadedBook(book.id);
                    } else {
                      await offlineService.downloadBook(book.id);
                    }
                  },
                  tooltip: isDownloaded ? 'Remove from offline' : 'Download for offline',
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            );
          },
        ),
        InteractiveIconButton(
          icon: Icons.share,
          iconColor: Colors.white,
          size: 32,
          onPressed: () async {
            final shareService = ShareService();
            await shareService.shareBook(book);
          },
          tooltip: 'Share',
        ),
      ],
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
    );
  }
  
  Widget _buildPlaceholderCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: const Center(
        child: Icon(Icons.book, size: 100, color: Colors.white70),
      ),
    );
  }
  
  Widget _buildTitleSection(BuildContext context, BookModel book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (book.authors.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  book.authors.join(', '),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
  
  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    BookModel book,
    AsyncValue libraryItemAsync,
  ) {
    return Row(
      children: [
        Expanded(
          child: libraryItemAsync.when(
            data: (item) {
              final isInLibrary = item != null;
              return PremiumButton(
                label: isInLibrary ? 'Continue Reading' : 'Add to Library',
                icon: isInLibrary ? Icons.play_arrow : Icons.add,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                ),
                onPressed: () {
                  if (isInLibrary) {
                    context.push('/reading/${book.id}');
                  } else {
                    ref.read(libraryControllerProvider).addToLibrary(book.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to library')),
                    );
                  }
                },
              );
            },
            loading: () => PremiumButton(
              label: 'Loading...',
              onPressed: null,
            ),
            error: (_, __) => PremiumButton(
              label: 'Add to Library',
              icon: Icons.add,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              onPressed: () {
                ref.read(libraryControllerProvider).addToLibrary(book.id);
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        PremiumButton(
          label: 'Read Now',
          icon: Icons.book,
          isOutlined: true,
          color: AppColors.primary,
          onPressed: () => context.push('/reading/${book.id}'),
        ),
      ],
    );
  }
  
  Widget _buildStatsCards(
    BuildContext context,
    WidgetRef ref,
    BookModel book,
    AsyncValue averageRatingAsync,
  ) {
    return Row(
      children: [
        Expanded(
          child: PremiumCard(
            child: Column(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 28),
                const SizedBox(height: 8),
                averageRatingAsync.when(
                  data: (rating) => Text(
                    rating != null ? rating.toStringAsFixed(1) : 'N/A',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('N/A'),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rating',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PremiumCard(
            child: Column(
              children: [
                Icon(Icons.menu_book, color: Colors.blue, size: 28),
                const SizedBox(height: 8),
                Text(
                  '${book.totalChapters}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chapters',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PremiumCard(
            child: Column(
              children: [
                Icon(Icons.visibility, color: Colors.green, size: 28),
                const SizedBox(height: 8),
                Text(
                  '${book.totalReads}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reads',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildRatingSection(
    BuildContext context,
    WidgetRef ref,
    BookModel book,
    AsyncValue userRatingAsync,
    AsyncValue averageRatingAsync,
  ) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rating',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              averageRatingAsync.when(
                data: (rating) => rating != null
                    ? Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < rating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 24,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'No ratings yet',
                        style: TextStyle(color: Colors.white70),
                      ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text(
                  'Error',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          userRatingAsync.when(
            data: (userRating) {
              if (userRating == null) {
                return PremiumButton(
                  label: 'Rate this book',
                  icon: Icons.star_outline,
                  isOutlined: true,
                  color: AppColors.primary,
                  onPressed: () {
                    _showRatingDialog(context, ref, book);
                  },
                );
              }
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(5, (index) {
                        return InteractiveIconButton(
                          icon: index < userRating.rating
                              ? Icons.star
                              : Icons.star_border,
                          iconColor: Colors.amber,
                          size: 36,
                          onPressed: () async {
                            try {
                              await ref.read(socialControllerProvider).rateBook(
                                bookId: book.id,
                                rating: index + 1,
                                review: userRating.review,
                              );
                              ref.invalidate(userRatingProvider(book.id));
                              ref.invalidate(bookAverageRatingProvider(book.id));
                              ref.invalidate(bookReviewsProvider(book.id));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Rating updated!')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                          tooltip: '${index + 1} stars',
                        );
                      }),
                    ],
                  ),
                  if (userRating.review != null && userRating.review!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    InteractiveButton(
                      label: 'Edit Review',
                      icon: Icons.edit,
                      onPressed: () {
                        _showRatingDialog(context, ref, book, initialRating: userRating.rating, initialReview: userRating.review);
                      },
                      isOutlined: true,
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    InteractiveButton(
                      label: 'Add Review',
                      icon: Icons.add_comment,
                      onPressed: () {
                        _showRatingDialog(context, ref, book, initialRating: userRating.rating);
                      },
                      isOutlined: true,
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ],
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDescriptionSection(BuildContext context, BookModel book) {
    if (book.description == null || book.description!.isEmpty) {
      return const SizedBox();
    }
    
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            book.description!,
            style: const TextStyle(
              color: Colors.white,
              height: 1.6,
              fontSize: 16,
            ),
            maxLines: _isDescriptionExpanded ? null : 4,
            overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
          ),
          if (book.description!.length > 200) ...[
            const SizedBox(height: 8),
            InteractiveButton(
              label: _isDescriptionExpanded ? 'Show less' : 'Show more',
              icon: _isDescriptionExpanded ? Icons.expand_less : Icons.expand_more,
              onPressed: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
              isOutlined: true,
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildChaptersSection(BuildContext context, WidgetRef ref, BookModel book) {
    final chaptersAsync = ref.watch(chaptersByBookIdProvider(book.id));
    
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chapters (${book.totalChapters})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              InteractiveButton(
                label: 'View All',
                icon: Icons.arrow_forward,
                onPressed: () {
                  _showAllChaptersDialog(context, ref, book);
                },
                isOutlined: true,
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          chaptersAsync.when(
            data: (chapters) {
              if (chapters.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No chapters available',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              
              // Show first 5 chapters
              final displayChapters = chapters.take(5).toList();
              
              return Column(
                children: [
                  ...displayChapters.asMap().entries.map((entry) {
                    final index = entry.key;
                    final chapter = entry.value;
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: ListTile(
                            leading: Container(
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
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              chapter.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: chapter.subtitle != null
                                ? Text(
                                    chapter.subtitle!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  )
                                : chapter.estimatedReadingTimeMinutes != null
                                    ? Text(
                                        '${chapter.estimatedReadingTimeMinutes} min read',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      )
                                    : null,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              context.push('/reading/${book.id}?chapterId=${chapter.id}');
                            },
                          ),
                        ),
                      ),
                    );
                  }),
                  if (chapters.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: InteractiveButton(
                        label: 'Show ${chapters.length - 5} more chapters',
                        icon: Icons.arrow_forward,
                        onPressed: () => _showAllChaptersDialog(context, ref, book),
                        isOutlined: true,
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error loading chapters: $error',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAllChaptersDialog(BuildContext context, WidgetRef ref, BookModel book) {
    final chaptersAsync = ref.read(chaptersByBookIdProvider(book.id));
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Chapters (${book.totalChapters})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    InteractiveIconButton(
                      icon: Icons.close,
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              // Chapters list
              Flexible(
                child: chaptersAsync.when(
                  data: (chapters) {
                    if (chapters.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'No chapters available',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = chapters[index];
                        return ListTile(
                          leading: Container(
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
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            chapter.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: chapter.subtitle != null
                              ? Text(
                                  chapter.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                )
                              : chapter.estimatedReadingTimeMinutes != null
                                  ? Text(
                                      '${chapter.estimatedReadingTimeMinutes} min read',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    )
                                  : null,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/reading/${book.id}?chapterId=${chapter.id}');
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildReviewsSection(BuildContext context, WidgetRef ref, BookModel book) {
    final reviewsAsync = ref.watch(bookReviewsProvider(book.id));
    
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reviews',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              InteractiveButton(
                label: 'View All',
                icon: Icons.arrow_forward,
                onPressed: () {
                  context.push('/book/${book.id}/comments');
                },
                isOutlined: true,
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          reviewsAsync.when(
            data: (reviews) {
              if (reviews.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.rate_review_outlined, size: 48, color: AppColors.textSecondaryLight),
                      const SizedBox(height: 8),
                      const Text(
                        'No reviews yet',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PremiumButton(
                        label: 'Write a Review',
                        icon: Icons.edit,
                        isOutlined: true,
                        color: AppColors.primary,
                        onPressed: () {
                          _showRatingDialog(context, ref, book);
                        },
                      ),
                    ],
                  ),
                );
              }
              
              // Show first 3 reviews
              final displayReviews = reviews.take(3).toList();
              
              return Column(
                children: [
                  ...displayReviews.asMap().entries.map((entry) {
                    final index = entry.key;
                    final review = entry.value;
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Container(
                            margin: EdgeInsets.only(bottom: index < displayReviews.length - 1 ? 16 : 0),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Rating stars
                                Row(
                                  children: [
                                    ...List.generate(5, (i) {
                                      return Icon(
                                        i < review.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDate(review.createdAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Review text
                                Text(
                                  review.review!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.white,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (reviews.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: InteractiveButton(
                        label: 'View ${reviews.length - 3} more reviews',
                        icon: Icons.arrow_forward,
                        onPressed: () => context.push('/book/${book.id}/comments'),
                        isOutlined: true,
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error loading reviews: $error',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  void _showRatingDialog(
    BuildContext context,
    WidgetRef ref,
    BookModel book, {
    int? initialRating,
    String? initialReview,
  }) {
    int selectedRating = initialRating ?? 0;
    final reviewController = TextEditingController(text: initialReview ?? '');
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Rate this book'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rating stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return InteractiveIconButton(
                    icon: index < selectedRating
                        ? Icons.star
                        : Icons.star_border,
                    iconColor: Colors.amber,
                    size: 36,
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                    tooltip: '${index + 1} stars',
                  );
                }),
              ),
              const SizedBox(height: 16),
              // Review text field
              TextField(
                controller: reviewController,
                decoration: const InputDecoration(
                  labelText: 'Write a review (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Share your thoughts about this book...',
                ),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            InteractiveButton(
              label: 'Cancel',
              onPressed: () => Navigator.pop(context),
              isOutlined: true,
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            InteractiveButton(
              label: 'Submit',
              icon: Icons.check,
              onPressed: selectedRating > 0
                  ? () async {
                      final controller = ref.read(socialControllerProvider);
                      await controller.rateBook(
                        bookId: book.id,
                        rating: selectedRating,
                        review: reviewController.text.isNotEmpty
                            ? reviewController.text
                            : null,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Review submitted!')),
                        );
                        ref.invalidate(bookReviewsProvider(book.id));
                        ref.invalidate(bookAverageRatingProvider(book.id));
                      }
                    }
                  : null,
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoriesSection(BuildContext context, BookModel book) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: book.categories.map((category) {
        return Chip(
          label: Text(category),
          backgroundColor: AppColors.primary.withOpacity(0.1),
          labelStyle: TextStyle(color: AppColors.primary),
        );
      }).toList(),
    );
  }
  
  Widget _buildSimilarBooksSection(
    BuildContext context,
    WidgetRef ref,
    BookModel book,
  ) {
    final similarAsync = ref.watch(similarBooksProvider(book.id));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Similar Books',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: similarAsync.when(
            data: (books) {
              if (books.isEmpty) return const SizedBox();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 12),
                          child: InkWell(
                            onTap: () => context.push('/book/${books[index].id}'),
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 154,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[300],
                                  ),
                                  child: books[index].coverImageUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            books[index].coverImageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.book),
                                          ),
                                        )
                                      : const Icon(Icons.book),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  height: 32,
                                  child: Text(
                                    books[index].title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) => const ShimmerBookCard(),
            ),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ],
    );
  }
}

