import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../providers/admin_stats_provider.dart';
import '../providers/recent_data_provider.dart';

/// Admin Dashboard với thống kê và navigation
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  _buildQuickActionsSection(context),
                  const SizedBox(height: 32),
                  _buildManagementSection(
                    context,
                    ref,
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
                color: AppColors.textPrimaryLight,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Quản lý nội dung và hệ thống',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppColors.textSecondaryLight),
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
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton(
                context,
                label: 'Upload Sách',
                icon: Icons.upload_file,
                onPressed: () => context.push('/admin/upload-book'),
              ),
              _buildActionButton(
                context,
                label: 'Quản Lý Sách',
                icon: Icons.library_books,
                onPressed: () => context.push('/admin/manage-books'),
              ),
              _buildActionButton(
                context,
                label: 'Quản Lý Chapters',
                icon: Icons.menu_book,
                onPressed: () => context.push('/admin/manage-chapters'),
              ),
              _buildActionButton(
                context,
                label: 'Quản Lý Users',
                icon: Icons.people,
                onPressed: () => context.push('/admin/manage-users'),
              ),
              _buildActionButton(
                context,
                label: 'Quản Lý Comments',
                icon: Icons.comment,
                onPressed: () => context.push('/admin/manage-comments'),
              ),
              _buildActionButton(
                context,
                label: 'Quản Lý Categories',
                icon: Icons.category,
                onPressed: () => context.push('/admin/manage-categories'),
              ),
              _buildActionButton(
                context,
                label: 'System Settings',
                icon: Icons.settings,
                onPressed: () => context.push('/admin/system-settings'),
              ),
              _buildActionButton(
                context,
                label: 'Seed Data',
                icon: Icons.storage,
                onPressed: () => context.push('/admin/seed-data'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InteractiveButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      isOutlined: true,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }

  Widget _buildManagementSection(
    BuildContext context,
    WidgetRef ref,
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
                      color: AppColors.textPrimaryLight,
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
                        color: AppColors.textSecondaryLight,
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
            error: (_, __) => const Center(child: Text('Error loading books')),
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
                      color: AppColors.textPrimaryLight,
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
                        color: AppColors.textSecondaryLight,
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
            error: (_, __) => const Center(child: Text('Error loading users')),
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
