import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../stats/presentation/providers/stats_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserModelProvider);
    final statsAsync = ref.watch(readingStatsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          userAsync.when(
            data: (user) => Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? 'User',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Icon(Icons.error),
          ),
          const SizedBox(height: 32),
          
          // Stats
          statsAsync.when(
            data: (stats) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Books Read', '${stats?.totalBooksCompleted ?? 0}'),
                _buildStatItem('Reading Streak', '${stats?.currentStreak ?? 0} days'),
                _buildStatItem('Total Pages', '${stats?.totalPagesRead ?? 0}'),
              ],
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 32),
          
          // Menu Items
          _buildMenuItem(
            context,
            icon: Icons.library_books,
            title: AppStrings.myLibrary,
            onTap: () => context.go('/library'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.bar_chart,
            title: AppStrings.readingStats,
            onTap: () => context.go('/stats'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.recommend,
            title: 'Recommendations',
            onTap: () => context.go('/recommendations'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.leaderboard,
            title: AppStrings.leaderboard,
            onTap: () => context.go('/leaderboard'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: AppStrings.settings,
            onTap: () => context.go('/settings'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: AppStrings.logout,
            onTap: () async {
              try {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout error: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

