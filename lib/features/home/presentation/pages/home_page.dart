import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/top_navigation_bar.dart';
import '../../../../core/widgets/footer_widget.dart';
import '../../../../core/widgets/book_carousel.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../providers/book_provider.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../../recommendations/presentation/providers/recommendation_provider.dart';
import '../../../../data/models/book_model.dart';
import '../../../../data/models/library_item_model.dart';
import '../../../offline/presentation/widgets/offline_indicator.dart';
import '../widgets/dark_book_card.dart';
import '../../../../core/widgets/dark_bottom_nav_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final PageController _carouselController = PageController();
  int _currentCarouselPage = 0;

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredBooksAsync = ref.watch(featuredBooksProvider);
    final trendingBooksAsync = ref.watch(trendingBooksProvider);
    final personalizedAsync = ref.watch(personalizedRecommendationsProvider);
    final newReleasesAsync = ref.watch(newReleasesProvider);
    final hotThisWeekAsync = ref.watch(hotThisWeekProvider);
    final risingStarsAsync = ref.watch(risingStarsProvider);
    final editorsPicksAsync = ref.watch(editorsPicksProvider);
    final continueReadingAsync = ref.watch(
      libraryItemsProvider(AppConstants.bookStatusReading),
    );

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const TopNavigationBar(),
      body: Column(
        children: [
          // Offline indicator
          const OfflineIndicator(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Hero Banner Section (giống Waka)
                _buildHeroBanner(context, ref, featuredBooksAsync),

                // Search Bar
                _buildSearchBar(),

                // Continue Reading Section
                _buildContinueReadingSection(
                  context,
                  ref,
                  continueReadingAsync,
                ),

                // Trending Books Section (giống Wattpad)
                _buildTrendingSection(context, ref, trendingBooksAsync),

                // New Releases Section
                _buildNewReleasesSection(context, ref, newReleasesAsync),

                // Hot This Week Section
                _buildHotThisWeekSection(context, ref, hotThisWeekAsync),

                // Rising Stars Section
                _buildRisingStarsSection(context, ref, risingStarsAsync),

                // Editor's Picks Section
                _buildEditorsPicksSection(context, ref, editorsPicksAsync),

                // Personalized Recommendations
                _buildPersonalizedSection(context, ref, personalizedAsync),

                // Featured Books Section
                _buildFeaturedBooksSection(context, ref, featuredBooksAsync),

                // Spacing and divider before footer
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Divider
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.grey[300]!,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // Footer
                const SliverToBoxAdapter(child: FooterWidget()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const DarkBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BookModel>> featuredAsync,
  ) {
    return SliverToBoxAdapter(
      child: featuredAsync.when(
        data: (books) {
          if (books.isEmpty) return const SizedBox();

          // Take up to 5 featured books for carousel
          final carouselBooks = books.take(5).toList();

          return Container(
            height: 240,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Stack(
              children: [
                // Carousel
                PageView.builder(
                  controller: _carouselController,
                  onPageChanged: (index) {
                    setState(() => _currentCarouselPage = index);
                  },
                  itemCount: carouselBooks.length,
                  itemBuilder: (context, index) {
                    final book = carouselBooks[index];
                    return _buildCarouselItem(context, ref, book);
                  },
                ),

                // Page Indicators
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      carouselBooks.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentCarouselPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentCarouselPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Container(
          height: 240,
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildCarouselItem(
    BuildContext context,
    WidgetRef ref,
    BookModel book,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            book.coverImageUrl != null
                ? Image.network(
                    book.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                  ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.authors.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        book.authors.join(', '),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InteractiveButton(
                            label: 'Read Now',
                            icon: Icons.book_rounded,
                            onPressed: () => context.push('/book/${book.id}'),
                            backgroundColor: Colors.white,
                            textColor: AppColors.primary,
                            iconColor: AppColors.primary,
                            height: 36,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildBookmarkButton(context, ref, book),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(
    BuildContext context,
    WidgetRef ref,
    BookModel book,
  ) {
    final libraryItemAsync = ref.watch(libraryItemByBookIdProvider(book.id));

    return libraryItemAsync.when(
      data: (libraryItem) {
        final isInLibrary = libraryItem != null;
        return InteractiveIconButton(
          icon: isInLibrary ? Icons.bookmark : Icons.bookmark_border,
          iconColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.2),
          size: 36,
          onPressed: () async {
            try {
              final controller = ref.read(libraryControllerProvider);
              if (isInLibrary) {
                await controller.removeFromLibrary(book.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removed from library')),
                  );
                }
              } else {
                await controller.addToLibrary(book.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to library')),
                  );
                }
              }
              ref.invalidate(libraryItemByBookIdProvider(book.id));
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          tooltip: isInLibrary ? 'Remove from library' : 'Add to library',
        );
      },
      loading: () => InteractiveIconButton(
        icon: Icons.bookmark_border,
        iconColor: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.2),
        size: 36,
        onPressed: null,
      ),
      error: (_, __) => InteractiveIconButton(
        icon: Icons.bookmark_border,
        iconColor: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.2),
        size: 36,
        onPressed: () async {
          try {
            final controller = ref.read(libraryControllerProvider);
            await controller.addToLibrary(book.id);
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Added to library')));
            }
            ref.invalidate(libraryItemByBookIdProvider(book.id));
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        },
        tooltip: 'Add to library',
      ),
    );
  }

  Widget _buildContinueReadingSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<LibraryItemModel>> continueReadingAsync,
  ) {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                context,
                title: 'Continue Reading',
                emoji: '📖',
                onSeeAll: () => context.go('/library'),
              ),
              continueReadingAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: EmptyState(
                        title: 'No recent reading',
                        message: 'Start reading a book to see it here',
                        icon: Icons.book_outlined,
                      ),
                    );
                  }

                  return SizedBox(
                    height: 380,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _buildContinueReadingCard(
                                context,
                                ref,
                                items[index],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => SizedBox(
                  height: 380,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 3,
                    itemBuilder: (context, index) => const ShimmerBookCard(),
                  ),
                ),
                error: (error, stack) => ErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(
                    libraryItemsProvider(AppConstants.bookStatusReading),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueReadingCard(
    BuildContext context,
    WidgetRef ref,
    LibraryItemModel item,
  ) {
    final bookAsync = ref.watch(bookByIdProvider(item.bookId));

    return bookAsync.when(
      data: (book) {
        if (book == null) return const SizedBox();

        return DarkBookCard(
          book: book,
          isHorizontal: true,
          progress: item.progress,
          status: 'Reading',
          actionLabel: 'Continue Reading',
          onActionTap: () {
            context.push(
              '/reading/${book.id}?chapterId=${item.currentChapter}',
            );
          },
          onTap: () => context.push('/book/${book.id}'),
        );
      },
      loading: () => const ShimmerBookCard(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildNewReleasesSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BookModel>> newReleasesAsync,
  ) {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: newReleasesAsync.when(
            data: (books) {
              if (books.isEmpty) return const SizedBox();
              return BookCarousel(
                books: books,
                title: 'New Releases',
                onSeeAll: () => context.go('/categories'),
              );
            },
            loading: () => const SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ),
    );
  }

  Widget _buildHotThisWeekSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BookModel>> hotThisWeekAsync,
  ) {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: hotThisWeekAsync.when(
            data: (books) {
              if (books.isEmpty) return const SizedBox();
              return BookCarousel(
                books: books,
                title: 'Hot This Week',
                onSeeAll: () => context.go('/recommendations'),
              );
            },
            loading: () => const SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ),
    );
  }

  Widget _buildRisingStarsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BookModel>> risingStarsAsync,
  ) {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: risingStarsAsync.when(
            data: (books) {
              if (books.isEmpty) return const SizedBox();
              return BookCarousel(
                books: books,
                title: 'Rising Stars',
                onSeeAll: () => context.go('/recommendations'),
              );
            },
            loading: () => const SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ),
    );
  }

  Widget _buildEditorsPicksSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BookModel>> editorsPicksAsync,
  ) {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: editorsPicksAsync.when(
            data: (books) {
              if (books.isEmpty) return const SizedBox();
              return BookCarousel(
                books: books,
                title: 'Editor\'s Picks',
                onSeeAll: () => context.go('/recommendations'),
              );
            },
            loading: () => const SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BookModel>> trendingAsync,
  ) {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: trendingAsync.when(
            data: (books) {
              if (books.isEmpty) return const SizedBox();
              return BookCarousel(
                books: books,
                title: 'Trending Now',
                onSeeAll: () => context.go('/recommendations'),
              );
            },
            loading: () => const SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalizedSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BookModel>> personalizedAsync,
  ) {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: personalizedAsync.when(
            data: (books) {
              if (books.isEmpty) return const SizedBox();
              return BookCarousel(
                books: books,
                title: 'For You',
                onSeeAll: () => context.go('/recommendations'),
              );
            },
            loading: () => const SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedBooksSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BookModel>> featuredAsync,
  ) {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: featuredAsync.when(
            data: (books) {
              if (books.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: EmptyState(
                    title: 'No featured books',
                    message: 'Check back later',
                    icon: Icons.book_outlined,
                  ),
                );
              }
              return BookCarousel(
                books: books,
                title: 'Featured Books',
                onSeeAll: () => context.go('/categories'),
              );
            },
            loading: () => const SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => ErrorState(
              message: error.toString(),
              onRetry: () => ref.invalidate(featuredBooksProvider),
            ),
          ),
        ),
      ),
    );
  }

  // Section Header với emoji cho dark theme
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? emoji,
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (emoji != null) ...[
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.darkTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'See All >',
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Search Bar cho dark theme
  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.darkTextSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                style: const TextStyle(color: AppColors.darkTextPrimary),
                decoration: InputDecoration(
                  hintText: 'Search books or authors...',
                  hintStyle: const TextStyle(color: AppColors.darkTextTertiary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (value) {
                  // TODO: Implement search
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
