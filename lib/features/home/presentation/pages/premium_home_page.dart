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

/// Premium HomePage inspired by Wattpad & Waka
class PremiumHomePage extends ConsumerWidget {
  const PremiumHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                
                // Quick Actions
                _buildQuickActions(context),
                
                // Continue Reading Section
                _buildContinueReadingSection(context, ref, continueReadingAsync),
                
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
                const SliverToBoxAdapter(
                  child: FooterWidget(),
                ),
              ],
            ),
          ),
        ],
      ),
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
          
          final heroBook = books.first;
          return Container(
            height: 280,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image với overlay
                  heroBook.coverImageUrl != null
                      ? Image.network(
                          heroBook.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primary,
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
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
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
                            heroBook.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (heroBook.authors.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              heroBook.authors.join(', '),
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: InteractiveButton(
                                  label: 'Read Now',
                                  icon: Icons.book,
                                  onPressed: () => context.push('/book/${heroBook.id}'),
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
                              Builder(
                                builder: (context) {
                                  final libraryItemAsync = ref.watch(libraryItemByBookIdProvider(heroBook.id));
                                  
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
                                              await controller.removeFromLibrary(heroBook.id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Removed from library')),
                                                );
                                              }
                                            } else {
                                              await controller.addToLibrary(heroBook.id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Added to library')),
                                                );
                                              }
                                            }
                                            ref.invalidate(libraryItemByBookIdProvider(heroBook.id));
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Error: $e')),
                                              );
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
                                          await controller.addToLibrary(heroBook.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Added to library')),
                                            );
                                          }
                                          ref.invalidate(libraryItemByBookIdProvider(heroBook.id));
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error: $e')),
                                            );
                                          }
                                        }
                                      },
                                      tooltip: 'Add to library',
                                    ),
                                  );
                                },
                              ),
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
        },
        loading: () => Container(
          height: 280,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[300],
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const SizedBox(),
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionButton(
              context,
              icon: Icons.explore,
              label: 'Discover',
              color: Colors.blue,
              onTap: () => context.go('/categories'),
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.trending_up,
              label: 'Trending',
              color: Colors.orange,
              onTap: () => context.go('/recommendations'),
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.collections_bookmark,
              label: 'Library',
              color: Colors.purple,
              onTap: () => context.go('/library'),
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.auto_awesome,
              label: 'For You',
              color: Colors.pink,
              onTap: () => context.go('/recommendations'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Continue Reading',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InteractiveButton(
                  label: 'See All',
                  icon: Icons.arrow_forward,
                  onPressed: () => context.go('/library'),
                  isOutlined: true,
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  textColor: AppColors.primary,
                  iconColor: AppColors.primary,
                ),
              ],
            ),
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
                height: 240,
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
                          child: _buildContinueReadingCard(context, ref, items[index]),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => SizedBox(
              height: 240,
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
        
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          child: InkWell(
            onTap: () => context.push('/book/${book.id}'),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Book cover với progress
                Stack(
                  children: [
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                      ),
                      child: book.coverImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                book.coverImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.book),
                              ),
                            )
                          : const Icon(Icons.book),
                    ),
                    // Progress indicator
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: item.progress.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(item.progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
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
}

