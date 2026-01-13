import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Extended admin statistics with more details
class ExtendedAdminStats {
  final int totalBooks;
  final int totalUsers;
  final int totalViews;
  final int totalChapters;
  final int publishedBooks;
  final int draftBooks;
  final int totalComments;
  final int totalRatings;
  final int totalBookmarks;
  final int totalCollections;
  final int totalLibraryItems;
  final int activeUsers; // Users with activity in last 30 days

  ExtendedAdminStats({
    required this.totalBooks,
    required this.totalUsers,
    required this.totalViews,
    required this.totalChapters,
    required this.publishedBooks,
    required this.draftBooks,
    required this.totalComments,
    required this.totalRatings,
    required this.totalBookmarks,
    required this.totalCollections,
    required this.totalLibraryItems,
    required this.activeUsers,
  });
}

/// Provider for extended admin statistics
final extendedAdminStatsProvider = FutureProvider<ExtendedAdminStats>((ref) async {
  final firestore = FirebaseService().firestore;

  // Get all stats in parallel
  final results = await Future.wait([
    // Total books
    firestore.collection(AppConstants.booksCollection).count().get(),
    // Total users
    firestore.collection(AppConstants.usersCollection).count().get(),
    // Total chapters
    firestore.collection(AppConstants.chaptersCollection).count().get(),
    // Published books
    firestore
        .collection(AppConstants.booksCollection)
        .where('isPublished', isEqualTo: true)
        .count()
        .get(),
    // Draft books
    firestore
        .collection(AppConstants.booksCollection)
        .where('isPublished', isEqualTo: false)
        .count()
        .get(),
    // Total comments
    firestore.collection(AppConstants.commentsCollection).count().get(),
    // Total ratings
    firestore.collection(AppConstants.ratingsCollection).count().get(),
    // Total bookmarks
    firestore.collection(AppConstants.bookmarksCollection).count().get(),
    // Total collections
    firestore.collection(AppConstants.collectionsCollection).count().get(),
    // Total library items
    firestore.collection(AppConstants.libraryCollection).count().get(),
  ]);

  // Calculate total views (sum of totalReads from all books)
  final booksSnapshot = await firestore
      .collection(AppConstants.booksCollection)
      .get();
  
  int totalViews = 0;
  for (var doc in booksSnapshot.docs) {
    final data = doc.data();
    totalViews += data['totalReads'] as int? ?? 0;
  }

  // Calculate active users (users with activity in last 30 days)
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  final activeUsersSnapshot = await firestore
      .collection(AppConstants.usersCollection)
      .where('lastLoginAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
      .count()
      .get();

  return ExtendedAdminStats(
    totalBooks: results[0].count ?? 0,
    totalUsers: results[1].count ?? 0,
    totalViews: totalViews,
    totalChapters: results[2].count ?? 0,
    publishedBooks: results[3].count ?? 0,
    draftBooks: results[4].count ?? 0,
    totalComments: results[5].count ?? 0,
    totalRatings: results[6].count ?? 0,
    totalBookmarks: results[7].count ?? 0,
    totalCollections: results[8].count ?? 0,
    totalLibraryItems: results[9].count ?? 0,
    activeUsers: activeUsersSnapshot.count ?? 0,
  );
});

/// Analytics Dashboard với thống kê chi tiết
class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(extendedAdminStatsProvider);
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.pagePadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.maxContentWidth(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Analytics Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thống kê tổng quan hệ thống',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 32),

              // Stats Grid
              statsAsync.when(
                data: (stats) => _buildStatsGrid(context, stats, isMobile),
                loading: () => _buildLoadingGrid(isMobile),
                error: (error, stack) => Center(
                  child: Text(
                    'Lỗi khi tải thống kê: $error',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Additional Stats
              statsAsync.when(
                data: (stats) => _buildAdditionalStats(context, stats, isMobile),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, ExtendedAdminStats stats, bool isMobile) {
    final crossAxisCount = isMobile ? 2 : 4;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 1.2 : 1.5,
      children: [
        _buildStatCard(
          context,
          title: 'Tổng Sách',
          value: stats.totalBooks.toString(),
          icon: Icons.library_books,
          color: AppColors.primary,
          subtitle: '${stats.publishedBooks} đã xuất bản',
        ),
        _buildStatCard(
          context,
          title: 'Tổng Users',
          value: stats.totalUsers.toString(),
          icon: Icons.people,
          color: Colors.blue,
          subtitle: '${stats.activeUsers} đang hoạt động',
        ),
        _buildStatCard(
          context,
          title: 'Tổng Views',
          value: stats.totalViews.toString(),
          icon: Icons.visibility,
          color: Colors.green,
          subtitle: 'Lượt đọc tổng cộng',
        ),
        _buildStatCard(
          context,
          title: 'Tổng Chapters',
          value: stats.totalChapters.toString(),
          icon: Icons.menu_book,
          color: Colors.purple,
          subtitle: 'Chapters trong hệ thống',
        ),
      ],
    );
  }

  Widget _buildLoadingGrid(bool isMobile) {
    final crossAxisCount = isMobile ? 2 : 4;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 1.2 : 1.5,
      children: List.generate(4, (index) => const ShimmerLoading(
        width: double.infinity,
        height: 120,
      )),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return AppCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalStats(BuildContext context, ExtendedAdminStats stats, bool isMobile) {
    final crossAxisCount = isMobile ? 2 : 3;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thống Kê Chi Tiết',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isMobile ? 1.5 : 2.0,
          children: [
            _buildDetailCard(
              context,
              title: 'Comments',
              value: stats.totalComments.toString(),
              icon: Icons.comment,
              color: Colors.orange,
            ),
            _buildDetailCard(
              context,
              title: 'Ratings',
              value: stats.totalRatings.toString(),
              icon: Icons.star,
              color: Colors.amber,
            ),
            _buildDetailCard(
              context,
              title: 'Bookmarks',
              value: stats.totalBookmarks.toString(),
              icon: Icons.bookmark,
              color: Colors.pink,
            ),
            _buildDetailCard(
              context,
              title: 'Collections',
              value: stats.totalCollections.toString(),
              icon: Icons.collections,
              color: Colors.teal,
            ),
            _buildDetailCard(
              context,
              title: 'Library Items',
              value: stats.totalLibraryItems.toString(),
              icon: Icons.my_library_books,
              color: Colors.indigo,
            ),
            _buildDetailCard(
              context,
              title: 'Draft Books',
              value: stats.draftBooks.toString(),
              icon: Icons.edit_note,
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
