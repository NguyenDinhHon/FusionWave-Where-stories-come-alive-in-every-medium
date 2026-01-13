import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../providers/admin_stats_provider.dart';
import '../providers/recent_data_provider.dart';
import '../providers/time_series_stats_provider.dart';

/// Admin Dashboard với thống kê và navigation
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  TimePeriod _selectedPeriod = TimePeriod.last30Days;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
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
                  if (isMobile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderText(context),
                        const SizedBox(height: 16),
                        _buildPrimaryActionButton(context, fullWidth: true),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildHeaderText(context)),
                        const SizedBox(width: 16),
                        _buildPrimaryActionButton(context),
                      ],
                    ),
                  const SizedBox(height: 32),
                  _buildStatsSection(
                    context,
                    ref,
                    constraints.maxWidth,
                  ),
                  const SizedBox(height: 32),
                  _buildTimeSeriesChartSection(
                    context,
                    isMobile,
                  ),
                  const SizedBox(height: 32),
                  _buildDistributionChartsSection(
                    context,
                    isMobile,
                  ),
                  const SizedBox(height: 32),
                  _buildTopBooksSection(
                    context,
                    isMobile,
                  ),
                  const SizedBox(height: 32),
                  _buildManagementSection(
                    context,
                    isMobile,
                  ),
                  const SizedBox(height: 32),
                  _buildRecentActivitySection(
                    context,
                    isMobile,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Quản lý nội dung và hệ thống',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.white70), // White text
        ),
      ],
    );
  }

  Widget _buildPrimaryActionButton(BuildContext context,
      {bool fullWidth = false}) {
    final button = InteractiveButton(
      label: 'Upload Sách',
      icon: Icons.add,
      onPressed: () => context.push('/admin/upload-book'),
      gradient: AppColors.primaryGradient,
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildStatsSection(
    BuildContext context,
    WidgetRef ref,
    double maxWidth,
  ) {
    final statsAsync = ref.watch(adminStatsProvider);
    final crossAxisCount = ResponsiveUtils.gridCountForWidth(
      maxWidth,
      minItemWidth: 220,
      maxCount: 4,
    );

    return statsAsync.when(
      data: (stats) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
        children: [
          _buildStatCard(
            context,
            title: 'Tổng Sách',
            value: stats.totalBooks.toString(),
            icon: Icons.library_books,
            color: AppColors.primary,
          ),
          _buildStatCard(
            context,
            title: 'Tổng Users',
            value: stats.totalUsers.toString(),
            icon: Icons.people,
            color: Colors.blue,
          ),
          _buildStatCard(
            context,
            title: 'Tổng Views',
            value: stats.totalViews.toString(),
            icon: Icons.visibility,
            color: Colors.green,
          ),
          _buildStatCard(
            context,
            title: 'Tổng Chapters',
            value: stats.totalChapters.toString(),
            icon: Icons.menu_book,
            color: Colors.purple,
          ),
        ],
      ),
      loading: () => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
        children: List.generate(4, (index) => const _ShimmerStatCard()),
      ),
      error: (error, stack) => Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error: $error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            InteractiveButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: () => ref.invalidate(adminStatsProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54, // Darker for better contrast
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSection(
    BuildContext context,
    bool isMobile,
  ) {
    final recentBooksAsync = ref.watch(recentBooksProvider);
    final recentUsersAsync = ref.watch(recentUsersProvider);

    Widget booksCard = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                    Text(
                      'Recent Books',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text
                      ),
                    ),
              TextButton(
                onPressed: () => context.push('/admin/manage-books'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          recentBooksAsync.when(
            data: (books) {
              if (books.isEmpty) {
                return const Center(child: Text('No books yet'));
              }
              return Column(
                children: books.map((book) {
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: book.coverImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                book.coverImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.book),
                              ),
                            )
                          : const Icon(Icons.book),
                    ),
                    title: Text(
                      book.title,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      book.authors.isNotEmpty
                          ? book.authors.join(', ')
                          : 'Unknown',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54, // Darker for better contrast
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: book.isPublished
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          )
                        : const Icon(
                            Icons.circle_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                    onTap: () => context.push('/admin/edit-book/${book.id}'),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Center(child: Text('Error loading books')),
          ),
        ],
      ),
    );

    Widget usersCard = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                    Text(
                      'Recent Users',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text
                      ),
                    ),
              TextButton(
                onPressed: () => context.push('/admin/manage-users'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          recentUsersAsync.when(
            data: (users) {
              if (users.isEmpty) {
                return const Center(child: Text('No users yet'));
              }
              return Column(
                children: users.map((user) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: user['photoUrl'] != null
                          ? NetworkImage(user['photoUrl'])
                          : null,
                      child: user['photoUrl'] == null
                          ? Text(
                              (user['displayName'] as String).isNotEmpty
                                  ? (user['displayName'] as String)[0]
                                      .toUpperCase()
                                  : 'U',
                            )
                          : null,
                    ),
                    title: Text(
                      user['displayName'] ?? 'Unknown',
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      user['email'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54, // Darker for better contrast
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: user['role'] == AppConstants.roleAdmin
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user['role'] ?? AppConstants.roleUser,
                        style: TextStyle(
                          fontSize: 10,
                          color: user['role'] == AppConstants.roleAdmin
                              ? Colors.red
                              : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => context.push('/admin/manage-users'),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Center(child: Text('Error loading users')),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          booksCard,
          const SizedBox(height: 16),
          usersCard,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: booksCard),
        const SizedBox(width: 16),
        Expanded(child: usersCard),
      ],
    );
  }

  Widget _buildRecentActivitySection(
    BuildContext context,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoạt Động Gần Đây',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 16),
        if (isMobile)
          Column(
            children: [
              _buildActivityCardWithProvider(
                context,
                ref: ref,
                icon: Icons.comment,
                title: 'Comments',
                provider: recentCommentsCountProvider,
                route: '/admin/manage-comments',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildActivityCardWithProvider(
                context,
                ref: ref,
                icon: Icons.star,
                title: 'Ratings',
                provider: recentRatingsCountProvider,
                route: '/admin/manage-ratings',
                color: Colors.amber,
              ),
              const SizedBox(height: 12),
              _buildActivityCardWithProvider(
                context,
                ref: ref,
                icon: Icons.bookmark,
                title: 'Bookmarks',
                provider: recentBookmarksCountProvider,
                route: '/admin/manage-bookmarks',
                color: Colors.pink,
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildActivityCardWithProvider(
                  context,
                  ref: ref,
                  icon: Icons.comment,
                  title: 'Comments',
                  provider: recentCommentsCountProvider,
                  route: '/admin/manage-comments',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActivityCardWithProvider(
                  context,
                  ref: ref,
                  icon: Icons.star,
                  title: 'Ratings',
                  provider: recentRatingsCountProvider,
                  route: '/admin/manage-ratings',
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActivityCardWithProvider(
                  context,
                  ref: ref,
                  icon: Icons.bookmark,
                  title: 'Bookmarks',
                  provider: recentBookmarksCountProvider,
                  route: '/admin/manage-bookmarks',
                  color: Colors.pink,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActivityCardWithProvider(
    BuildContext context, {
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required FutureProvider<int> provider,
    required String route,
    required Color color,
  }) {
    final countAsync = ref.watch(provider);
    
    return AppCard(
      child: InkWell(
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    countAsync.when(
                      data: (count) => Text(
                        count.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      loading: () => const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (_, _) => const Text(
                        '0',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodFilter(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<TimePeriod>(
        value: _selectedPeriod,
        underline: const SizedBox.shrink(),
        dropdownColor: Colors.grey[900],
        style: const TextStyle(color: Colors.white),
        items: TimePeriod.values.map((period) {
          return DropdownMenuItem<TimePeriod>(
            value: period,
            child: Text(
              period.label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.87)),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedPeriod = value;
            });
          }
        },
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      ),
    );
  }

  Widget _buildTimeSeriesChartSection(
    BuildContext context,
    bool isMobile,
  ) {
    final timeSeriesStatsAsync = ref.watch(timeSeriesStatsProvider(_selectedPeriod));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Thống Kê Theo Thời Gian',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            _buildTimePeriodFilter(isMobile),
          ],
        ),
        const SizedBox(height: 16),
        timeSeriesStatsAsync.when(
          data: (data) {
            if (data.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Chưa có dữ liệu', style: TextStyle(color: Colors.white70)),
                ),
              );
            }
            return AppCard(
              child: SizedBox(
                height: isMobile ? 300 : 400,
                child: _buildTimeSeriesChart(data, isMobile),
              ),
            );
          },
          loading: () => AppCard(
            child: SizedBox(
              height: isMobile ? 300 : 400,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => AppCard(
            child: SizedBox(
              height: isMobile ? 300 : 400,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text('Error: $error', style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeriesChart(List<TimeSeriesData> data, bool isMobile) {
    final maxBooks = data.map((e) => e.books).reduce((a, b) => a > b ? a : b);
    final maxUsers = data.map((e) => e.users).reduce((a, b) => a > b ? a : b);
    final maxViews = data.map((e) => e.views).reduce((a, b) => a > b ? a : b);
    final maxComments = data.map((e) => e.comments).reduce((a, b) => a > b ? a : b);
    final maxRatings = data.map((e) => e.ratings).reduce((a, b) => a > b ? a : b);
    
    final maxY = [
      maxBooks,
      maxUsers,
      maxViews,
      maxComments,
      maxRatings,
    ].reduce((a, b) => a > b ? a : b) * 1.2;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? (maxY / 5).clamp(1.0, double.infinity) : 1.0,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: isMobile ? 5 : 3,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final date = data[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.day}/${date.month}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.books.toDouble());
            }).toList(),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.users.toDouble());
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.1),
            ),
          ),
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.views.toDouble());
            }).toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildDistributionChartsSection(
    BuildContext context,
    bool isMobile,
  ) {
    final categoryDistAsync = ref.watch(categoryDistributionProvider);
    final bookStatusAsync = ref.watch(bookStatusDistributionProvider);
    final userActivityAsync = ref.watch(userActivityStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phân Phối Dữ Liệu',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 16),
        if (isMobile)
          Column(
            children: [
              _buildCategoryPieChart(context, ref, categoryDistAsync),
              const SizedBox(height: 16),
              _buildBookStatusBarChart(context, ref, bookStatusAsync),
              const SizedBox(height: 16),
              _buildUserActivityBarChart(context, ref, userActivityAsync),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildCategoryPieChart(context, ref, categoryDistAsync),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildBookStatusBarChart(context, ref, bookStatusAsync),
                    const SizedBox(height: 16),
                    _buildUserActivityBarChart(context, ref, userActivityAsync),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCategoryPieChart(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CategoryDistribution>> categoryDistAsync,
  ) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phân Phối Thể Loại',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: categoryDistAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Center(
                      child: Text('Chưa có dữ liệu', style: TextStyle(color: Colors.white70)),
                    );
                  }
                  final topCategories = categories.take(5).toList();
                  final othersCount = categories.skip(5).fold<int>(
                    0,
                    (sum, item) => sum + item.count,
                  );

                  final colors = [
                    AppColors.primary,
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                  ];

                  return PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: [
                        ...topCategories.asMap().entries.map((e) {
                          return PieChartSectionData(
                            value: e.value.count.toDouble(),
                            title: '${e.value.count}',
                            color: colors[e.key % colors.length],
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }),
                        if (othersCount > 0)
                          PieChartSectionData(
                            value: othersCount.toDouble(),
                            title: '$othersCount',
                            color: Colors.grey,
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            categoryDistAsync.when(
              data: (categories) {
                if (categories.isEmpty) return const SizedBox.shrink();
                final topCategories = categories.take(5).toList();
                final colors = [
                  AppColors.primary,
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                ];
                return Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: topCategories.asMap().entries.map((e) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[e.key % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${e.value.category}: ${e.value.count}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookStatusBarChart(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<BookStatusDistribution> bookStatusAsync,
  ) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trạng Thái Sách',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: bookStatusAsync.when(
                data: (status) {
                  final maxValue = (status.published + status.draft) * 1.2;
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxValue > 0 ? maxValue : 10,
                      barTouchData: const BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() == 0) {
                                return const Text(
                                  'Published',
                                  style: TextStyle(color: Colors.white70, fontSize: 10),
                                );
                              } else if (value.toInt() == 1) {
                                return const Text(
                                  'Draft',
                                  style: TextStyle(color: Colors.white70, fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxValue > 0 ? (maxValue / 5).clamp(1.0, double.infinity) : 1.0,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.white.withValues(alpha: 0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: status.published.toDouble(),
                              color: Colors.green,
                              width: 40,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: status.draft.toDouble(),
                              color: Colors.orange,
                              width: 40,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActivityBarChart(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<UserActivityStats> userActivityAsync,
  ) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hoạt Động Người Dùng',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: userActivityAsync.when(
                data: (activity) {
                  final maxValue = [
                    activity.activeLast7Days,
                    activity.activeLast30Days,
                    activity.totalActive,
                  ].reduce((a, b) => a > b ? a : b) * 1.2;
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxValue > 0 ? maxValue : 10,
                      barTouchData: const BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() == 0) {
                                return const Text(
                                  '7d',
                                  style: TextStyle(color: Colors.white70, fontSize: 10),
                                );
                              } else if (value.toInt() == 1) {
                                return const Text(
                                  '30d',
                                  style: TextStyle(color: Colors.white70, fontSize: 10),
                                );
                              } else if (value.toInt() == 2) {
                                return const Text(
                                  '90d',
                                  style: TextStyle(color: Colors.white70, fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxValue > 0 ? (maxValue / 5).clamp(1.0, double.infinity) : 1.0,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.white.withValues(alpha: 0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: activity.activeLast7Days.toDouble(),
                              color: Colors.blue,
                              width: 40,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: activity.activeLast30Days.toDouble(),
                              color: Colors.purple,
                              width: 40,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: activity.totalActive.toDouble(),
                              color: AppColors.primary,
                              width: 40,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBooksSection(
    BuildContext context,
    bool isMobile,
  ) {
    final topByViewsAsync = ref.watch(topBooksByViewsProvider);
    final topByRatingAsync = ref.watch(topBooksByRatingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Sách',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 16),
        if (isMobile)
          Column(
            children: [
              _buildTopBooksTable(
                context,
                'Top Sách Theo Lượt Xem',
                topByViewsAsync,
                (book) => '${book['views']} views',
              ),
              const SizedBox(height: 16),
              _buildTopBooksTable(
                context,
                'Top Sách Theo Đánh Giá',
                topByRatingAsync,
                (book) => '⭐ ${book['rating']?.toStringAsFixed(1)} (${book['totalRatings']} đánh giá)',
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTopBooksTable(
                  context,
                  'Top Sách Theo Lượt Xem',
                  topByViewsAsync,
                  (book) => '${book['views']} views',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTopBooksTable(
                  context,
                  'Top Sách Theo Đánh Giá',
                  topByRatingAsync,
                  (book) => '⭐ ${book['rating']?.toStringAsFixed(1)} (${book['totalRatings']} đánh giá)',
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTopBooksTable(
    BuildContext context,
    String title,
    AsyncValue<List<Map<String, dynamic>>> booksAsync,
    String Function(Map<String, dynamic>) getSubtitle,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
          ),
          booksAsync.when(
            data: (books) {
              if (books.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text('Chưa có dữ liệu', style: TextStyle(color: Colors.white70)),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: books.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.white.withValues(alpha: 0.1),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final book = books[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      book['title'] ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      getSubtitle(book),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    onTap: () => context.push('/admin/edit-book/${book['id']}'),
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerStatCard extends StatelessWidget {
  const _ShimmerStatCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 60, height: 20, color: Colors.grey[200]),
                const SizedBox(height: 8),
                Container(width: 80, height: 12, color: Colors.grey[200]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
