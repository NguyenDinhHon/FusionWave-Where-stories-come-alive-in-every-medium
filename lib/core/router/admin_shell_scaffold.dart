import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../widgets/interactive_button.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';

/// Admin Shell Scaffold với navigation riêng cho admin
class AdminShellScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AdminShellScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserModelProvider);
    
    return userAsync.when(
      data: (user) {
        // Check if user is admin
        if (user?.role != AppConstants.roleAdmin) {
          // Redirect to login if not admin
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              // Admin Sidebar
              _buildAdminSidebar(context, navigationShell, ref),
              // Main Content
              Expanded(
                child: navigationShell,
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const Scaffold(
        body: Center(child: Text('Error loading user data')),
      ),
    );
  }

  Widget _buildAdminSidebar(
    BuildContext context,
    StatefulNavigationShell navigationShell,
    WidgetRef ref,
  ) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          right: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Admin Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Panel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'FusionWave',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/admin',
                  currentIndex: navigationShell.currentIndex,
                  onTap: () {
                    context.go('/admin');
                    navigationShell.goBranch(0);
                  },
                ),
                const SizedBox(height: 8),
                _buildNavItem(
                  context,
                  icon: Icons.library_books,
                  label: 'Manage Books',
                  route: '/admin/manage-books',
                  currentIndex: navigationShell.currentIndex,
                  onTap: () {
                    context.go('/admin/manage-books');
                    navigationShell.goBranch(1);
                  },
                ),
                const SizedBox(height: 8),
                _buildNavItem(
                  context,
                  icon: Icons.menu_book,
                  label: 'Manage Chapters',
                  route: '/admin/manage-chapters',
                  currentIndex: navigationShell.currentIndex,
                  onTap: () {
                    context.go('/admin/manage-chapters');
                    navigationShell.goBranch(2);
                  },
                ),
                const SizedBox(height: 8),
                _buildNavItem(
                  context,
                  icon: Icons.people,
                  label: 'Manage Users',
                  route: '/admin/manage-users',
                  currentIndex: navigationShell.currentIndex,
                  onTap: () {
                    context.go('/admin/manage-users');
                    navigationShell.goBranch(3);
                  },
                ),
                const SizedBox(height: 8),
                _buildNavItem(
                  context,
                  icon: Icons.comment,
                  label: 'Manage Comments',
                  route: '/admin/manage-comments',
                  currentIndex: navigationShell.currentIndex,
                  onTap: () {
                    context.go('/admin/manage-comments');
                    navigationShell.goBranch(4);
                  },
                ),
                const SizedBox(height: 8),
                _buildNavItem(
                  context,
                  icon: Icons.category,
                  label: 'Manage Categories',
                  route: '/admin/manage-categories',
                  currentIndex: navigationShell.currentIndex,
                  onTap: () {
                    context.go('/admin/manage-categories');
                    navigationShell.goBranch(5);
                  },
                ),
                const SizedBox(height: 8),
                _buildNavItem(
                  context,
                  icon: Icons.settings,
                  label: 'System Settings',
                  route: '/admin/system-settings',
                  currentIndex: navigationShell.currentIndex,
                  onTap: () {
                    context.go('/admin/system-settings');
                    navigationShell.goBranch(6);
                  },
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                _buildNavItem(
                  context,
                  icon: Icons.upload_file,
                  label: 'Upload Book',
                  route: '/admin/upload-book',
                  currentIndex: navigationShell.currentIndex,
                  onTap: () {
                    context.push('/admin/upload-book');
                  },
                ),
              ],
            ),
          ),
          
          // Footer with logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                InteractiveButton(
                  label: 'Back to User View',
                  icon: Icons.person,
                  onPressed: () => context.go('/home'),
                  isOutlined: true,
                ),
                const SizedBox(height: 8),
                InteractiveButton(
                  label: 'Logout',
                  icon: Icons.logout,
                  onPressed: () async {
                    final authController = ref.read(authControllerProvider.notifier);
                    await authController.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  iconColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isActive = ModalRoute.of(context)?.settings.name == route ||
        (route == '/admin' && currentIndex == 0);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.iconLight,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textPrimaryLight,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
