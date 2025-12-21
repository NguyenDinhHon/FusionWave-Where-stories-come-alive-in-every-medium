import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../data/models/book_model.dart';
import '../providers/recommendation_provider.dart';

/// Enhanced Recommendations Page với AI suggestions
class EnhancedRecommendationsPage extends ConsumerWidget {
  const EnhancedRecommendationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personalizedAsync = ref.watch(personalizedRecommendationsProvider);
    final trendingAsync = ref.watch(trendingBooksProvider);
    final similarAsync = ref.watch(similarBooksProvider('')); // TODO: Get from current book
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recommendations'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'For You', icon: Icon(Icons.person)),
              Tab(text: 'Trending', icon: Icon(Icons.trending_up)),
              Tab(text: 'Similar', icon: Icon(Icons.auto_awesome)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPersonalizedRecommendations(context, ref, personalizedAsync),
            _buildTrendingBooks(context, ref, trendingAsync),
            _buildSimilarBooks(context, ref, similarAsync),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPersonalizedRecommendations(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BookModel>> async,
  ) {
    return async.when(
      data: (books) {
        if (books.isEmpty) {
          return EmptyState(
            title: 'No recommendations yet',
            message: 'Start reading to get personalized recommendations based on your preferences',
            icon: Icons.recommend_outlined,
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(personalizedRecommendationsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => context.push('/book/${books[index].id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
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
                                child: books[index].coverImageUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          books[index].coverImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.book),
                                        ),
                                      )
                                    : const Icon(Icons.book),
                              ),
                              const SizedBox(width: 12),
                              // Book info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.auto_awesome, size: 16, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            books[index].title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (books[index].authors.isNotEmpty)
                                      Text(
                                        books[index].authors.join(', '),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    const SizedBox(height: 4),
                                    if (books[index].categories.isNotEmpty)
                                      Wrap(
                                        spacing: 4,
                                        children: books[index].categories.take(2).map((category) {
                                          return Chip(
                                            label: Text(
                                              category,
                                              style: const TextStyle(fontSize: 10),
                                            ),
                                            padding: EdgeInsets.zero,
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          );
                                        }).toList(),
                                      ),
                                    if (books[index].averageRating != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 14, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${books[index].averageRating!.toStringAsFixed(1)} (${books[index].totalRatings})',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => const ShimmerListItem(),
      ),
      error: (error, stack) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(personalizedRecommendationsProvider),
      ),
    );
  }
  
  Widget _buildTrendingBooks(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BookModel>> async,
  ) {
    return async.when(
      data: (books) {
        if (books.isEmpty) {
          return EmptyState(
            title: 'No trending books',
            message: 'Check back later for trending content',
            icon: Icons.trending_up,
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(trendingBooksProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => context.push('/book/${books[index].id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Rank badge
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: index < 3 ? Colors.amber : Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: index < 3 ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Book cover
                              Container(
                                width: 60,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: books[index].coverImageUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          books[index].coverImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.book),
                                        ),
                                      )
                                    : const Icon(Icons.book),
                              ),
                              const SizedBox(width: 12),
                              // Book info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      books[index].title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    if (books[index].authors.isNotEmpty)
                                      Text(
                                        books[index].authors.join(', '),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (books[index].averageRating != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 14, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${books[index].averageRating!.toStringAsFixed(1)} (${books[index].totalRatings})',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.trending_up,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => const ShimmerListItem(),
      ),
      error: (error, stack) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(trendingBooksProvider),
      ),
    );
  }
  
  Widget _buildSimilarBooks(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BookModel>> async,
  ) {
    return async.when(
      data: (books) {
        if (books.isEmpty) {
          return EmptyState(
            title: 'No similar books',
            message: 'View a book to see similar recommendations',
            icon: Icons.auto_awesome,
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(similarBooksProvider(''));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => context.push('/book/${books[index].id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
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
                                child: books[index].coverImageUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          books[index].coverImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.book),
                                        ),
                                      )
                                    : const Icon(Icons.book),
                              ),
                              const SizedBox(width: 12),
                              // Book info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.compare_arrows, size: 16, color: Colors.blue),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            books[index].title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (books[index].authors.isNotEmpty)
                                      Text(
                                        books[index].authors.join(', '),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (books[index].categories.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 4,
                                        children: books[index].categories.take(2).map((category) {
                                          return Chip(
                                            label: Text(
                                              category,
                                              style: const TextStyle(fontSize: 10),
                                            ),
                                            padding: EdgeInsets.zero,
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                    if (books[index].averageRating != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 14, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${books[index].averageRating!.toStringAsFixed(1)}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => const ShimmerListItem(),
      ),
      error: (error, stack) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(similarBooksProvider('')),
      ),
    );
  }
}

