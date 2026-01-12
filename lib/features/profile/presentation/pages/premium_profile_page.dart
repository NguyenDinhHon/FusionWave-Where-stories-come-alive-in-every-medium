import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../core/widgets/top_navigation_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../stats/presentation/providers/stats_provider.dart';
import '../../../goals/presentation/providers/goals_provider.dart';

/// Premium Profile Page với design giống Wattpad & Waka
class PremiumProfilePage extends ConsumerWidget {
  const PremiumProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserModelProvider);
    final statsAsync = ref.watch(readingStatsProvider);
    final goalsAsync = ref.watch(readingGoalsProvider);
    
    return Scaffold(
      appBar: const TopNavigationBar(),
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InteractiveIconButton(
                      icon: Icons.settings,
                      iconColor: Colors.white,
                      size: 40,
                      onPressed: () => context.push('/settings'),
                      tooltip: 'Settings',
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Header Card
                  PremiumCard(
                    padding: const EdgeInsets.all(24),
                    child: userAsync.when(
                      data: (user) => Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                backgroundImage: user?.photoUrl != null
                                    ? NetworkImage(user!.photoUrl!)
                                    : null,
                                child: user?.photoUrl == null
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => context.push('/edit-profile'),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.displayName ?? 'User',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          PremiumButton(
                            label: 'Edit Profile',
                            icon: Icons.edit,
                            isOutlined: false,
                            color: AppColors.primary,
                            textColor: Colors.white,
                            iconColor: Colors.white,
                            onPressed: () => context.push('/edit-profile'),
                          ),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Icon(Icons.error),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stats Cards
                  statsAsync.when(
                    data: (stats) => Row(
                      children: [
                        Expanded(
                          child: PremiumCard(
                            child: Column(
                              children: [
                                Icon(Icons.menu_book, color: Colors.blue, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  '${stats?.totalBooksCompleted ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Books Read',
                                  style: TextStyle(
                                    color: AppColors.textSecondaryLight,
                                    fontSize: 12,
                                  ),
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
                                Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  '${stats?.currentStreak ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Day Streak',
                                  style: TextStyle(
                                    color: AppColors.textSecondaryLight,
                                    fontSize: 12,
                                  ),
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
                                Icon(Icons.description, color: Colors.green, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  '${stats?.totalPagesRead ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pages Read',
                                  style: TextStyle(
                                    color: AppColors.textSecondaryLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Daily Goal Card
                  PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daily Goal',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            InteractiveIconButton(
                              icon: Icons.edit,
                              onPressed: () => context.push('/goals'),
                              tooltip: 'Edit Goals',
                              size: 40,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final goal = goalsAsync;
                            return Column(
                              children: [
                                LinearProgressIndicator(
                                  value: goal.progress,
                                  backgroundColor: Colors.grey[300],
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${goal.todayMinutes} / ${goal.dailyGoalMinutes} minutes',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${(goal.progress * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color: AppColors.textSecondaryLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Menu Items
                  _buildMenuSection(context, ref),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    final menuItems = [
      {
        'icon': Icons.library_books,
        'title': 'My Library',
        'route': '/library',
        'color': Colors.blue,
      },
      {
        'icon': Icons.history,
        'title': 'Reading History',
        'route': '/history',
        'color': Colors.purple,
      },
      {
        'icon': Icons.bar_chart,
        'title': 'Statistics',
        'route': '/stats',
        'color': Colors.green,
      },
      {
        'icon': Icons.flag,
        'title': 'Reading Goals',
        'route': '/goals',
        'color': Colors.orange,
      },
      {
        'icon': Icons.collections_bookmark,
        'title': 'Collections',
        'route': '/collections',
        'color': Colors.pink,
      },
      {
        'icon': Icons.emoji_events,
        'title': 'Challenges',
        'route': '/challenges',
        'color': Colors.amber,
      },
      {
        'icon': Icons.notifications,
        'title': 'Notifications',
        'route': '/notifications',
        'color': Colors.red,
      },
      {
        'icon': Icons.cloud_download,
        'title': 'Offline Books',
        'route': '/offline',
        'color': Colors.teal,
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: PremiumCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  onTap: () => context.push(item['route'] as String),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondaryLight,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

