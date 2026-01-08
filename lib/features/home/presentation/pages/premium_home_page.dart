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
class PremiumHomePage extends ConsumerStatefulWidget {
  const PremiumHomePage({super.key});
  
  @override
  ConsumerState<PremiumHomePage> createState() => _PremiumHomePageState();
}

class _PremiumHomePageState extends ConsumerState<PremiumHomePage> {
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
                
                // Personalized Greeting
                _buildPersonalizedGreeting(context, ref),
                
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
  
  Widget _buildCarouselItem(BuildContext context, WidgetRef ref, BookModel book) {
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
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
  
  Widget _buildBookmarkButton(BuildContext context, WidgetRef ref, BookModel book) {
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
            await controller.addToLibrary(book.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to library')),
              );
            }
            ref.invalidate(libraryItemByBookIdProvider(book.id));
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
  }
  
  Widget _buildPersonalizedGreeting(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Determine greeting based on time of day
    String greeting;
    IconData greetingIcon;
    Color greetingColor;
    
    if (hour >= 5 && hour < 12) {
      greeting = 'Good morning';
      greetingIcon = Icons.wb_sunny;
      greetingColor = Colors.orange;
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
      greetingIcon = Icons.wb_sunny_outlined;
      greetingColor = Colors.amber;
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good evening';
      greetingIcon = Icons.wb_twilight;
      greetingColor = Colors.deepOrange;
    } else {
      greeting = 'Good night';
      greetingIcon = Icons.nightlight_round;
      greetingColor = Colors.indigo;
    }
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              greetingColor.withOpacity(0.1),
              greetingColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: greetingColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting header
            Row(
              children: [
                Icon(
                  greetingIcon,
                  color: greetingColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting, Reader!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready for your next story?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Stats row
            Row(
              children: [
                // Reading streak
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.local_fire_department,
                    iconColor: Colors.deepOrange,
                    value: '7',
                    label: 'Day Streak',
                  ),
                ),
                const SizedBox(width: 12),
                
                // Daily goal
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.menu_book,
                    iconColor: Colors.blue,
                    value: '2/5',
                    label: 'Chapters Today',
                  ),
                ),
                const SizedBox(width: 12),
                
                // Total books
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.auto_stories,
                    iconColor: Colors.purple,
                    value: '12',
                    label: 'Books Read',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
                          child: _buildContinueReadingCard(context, ref, items[index]),
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
        
        final progressPercent = (item.progress * 100).toStringAsFixed(0);
        final currentChapter = item.currentChapter;
        
        return Container(
          width: 200,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Book cover
              InkWell(
                onTap: () => context.push('/book/${book.id}'),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: book.coverImageUrl != null
                        ? Image.network(
                            book.coverImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 48),
                          )
                        : const Icon(Icons.book, size: 48),
                  ),
                ),
              ),
              
              // Content section
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Current chapter info
                    Row(
                      children: [
                        Icon(
                          Icons.bookmark,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Chapter $currentChapter',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Progress bar with percentage
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$progressPercent% complete',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: item.progress.clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Quick Resume button
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push('/reading/${book.id}?chapterId=${item.currentChapter}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

