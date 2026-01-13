import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../widgets/interactive_button.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';

/// Admin Shell Scaffold với navigation riêng cho admin
class AdminShellScaffold extends ConsumerWidget {
  static const List<_AdminNavDestination> _navDestinations = [
    _AdminNavDestination(
      icon: Icons.dashboard,
      label: 'Dashboard',
      route: '/admin',
      branchIndex: 0,
    ),
    _AdminNavDestination(
      icon: Icons.library_books,
      label: 'Manage Books',
      route: '/admin/manage-books',
      branchIndex: 1,
    ),
    _AdminNavDestination(
      icon: Icons.people,
      label: 'Manage Users',
      route: '/admin/manage-users',
      branchIndex: 2,
    ),
    _AdminNavDestination(
      icon: Icons.comment,
      label: 'Manage Comments',
      route: '/admin/manage-comments',
      branchIndex: 3,
    ),
    _AdminNavDestination(
      icon: Icons.star,
      label: 'Manage Ratings',
      route: '/admin/manage-ratings',
      branchIndex: 4,
    ),
    _AdminNavDestination(
      icon: Icons.category,
      label: 'Manage Categories',
      route: '/admin/manage-categories',
      branchIndex: 5,
    ),
    _AdminNavDestination(
      icon: Icons.analytics,
      label: 'Analytics',
      route: '/admin/analytics',
      branchIndex: 6,
    ),
    _AdminNavDestination(
      icon: Icons.bookmark,
      label: 'Manage Bookmarks',
      route: '/admin/manage-bookmarks',
      branchIndex: 7,
    ),
    _AdminNavDestination(
      icon: Icons.my_library_books,
      label: 'Manage Library',
      route: '/admin/manage-library-items',
      branchIndex: 8,
    ),
    _AdminNavDestination(
      icon: Icons.collections,
      label: 'Manage Collections',
      route: '/admin/manage-collections',
      branchIndex: 9,
    ),
    _AdminNavDestination(
      icon: Icons.settings,
      label: 'System Settings',
      route: '/admin/system-settings',
      branchIndex: 10,
    ),
    _AdminNavDestination(
      icon: Icons.upload_file,
      label: 'Upload Book',
      route: '/admin/upload-book',
      usePushNavigation: true,
    ),
  ];

  final StatefulNavigationShell navigationShell;

  const AdminShellScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // First check authControllerProvider (fast, already updated after login)
    final authState = ref.watch(authControllerProvider);
    final userFromAuth = authState.value;
    
    // If authController has user data, use it immediately
    if (userFromAuth != null) {
      // Check if user is admin
      if (userFromAuth.role != AppConstants.roleAdmin) {
        // Not admin, router guard will handle redirect
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      
      // User is admin, render immediately
      return LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          if (isMobile) {
            return _buildMobileScaffold(context, ref);
          }
          return _buildDesktopScaffold(context, ref);
        },
      );
    }
    
    // If authController is loading, show loading
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Fallback to currentUserModelProvider (Firestore stream) if authController doesn't have data
    final userAsync = ref.watch(currentUserModelProvider);
    
    return userAsync.when(
      data: (user) {
        // Check if user is admin
        if (user?.role != AppConstants.roleAdmin) {
          // Show loading while checking, don't redirect immediately
          // The router guard will handle redirect
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;
            if (isMobile) {
              return _buildMobileScaffold(context, ref);
            }
            return _buildDesktopScaffold(context, ref);
          },
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const Scaffold(
        body: Center(child: Text('Error loading user data')),
      ),
    );
  }

  Widget _buildDesktopScaffold(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          _buildAdminSidebar(context, navigationShell, ref),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  Widget _buildMobileScaffold(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildMobileAppBar(context, ref),
      drawer: _buildMobileDrawer(context, ref),
      body: navigationShell,
    );
  }

  PreferredSizeWidget _buildMobileAppBar(
    BuildContext context,
    WidgetRef ref,
  ) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      title: const Text(
        'Admin Panel',
        style: TextStyle(color: Colors.white), // White text
      ),
      iconTheme: const IconThemeData(color: Colors.white), // White icons
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Logout',
          icon: const Icon(Icons.logout),
          onPressed: () async {
            final authController = ref.read(authControllerProvider.notifier);
            await authController.signOut();
            if (context.mounted) {
              context.go('/login');
            }
          },
        ),
      ],
    );
  }

  Widget _buildMobileDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(context),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final destination = _navDestinations[index];
                  return _buildNavItem(
                    context,
                    destination: destination,
                    navigationShell: navigationShell,
                    currentIndex: navigationShell.currentIndex,
                    closeDrawerAfterTap: true,
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemCount: _navDestinations.length,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: InteractiveButton(
                label: 'Logout',
                icon: Icons.logout,
                onPressed: () async {
                  Navigator.of(context).pop();
                  final authController =
                      ref.read(authControllerProvider.notifier);
                  await authController.signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                iconColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
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
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final destination = _navDestinations[index];
                return _buildNavItem(
                  context,
                  destination: destination,
                  navigationShell: navigationShell,
                  currentIndex: navigationShell.currentIndex,
                );
              },
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemCount: _navDestinations.length,
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
            child: InteractiveButton(
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
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required _AdminNavDestination destination,
    required StatefulNavigationShell navigationShell,
    required int currentIndex,
    bool closeDrawerAfterTap = false,
  }) {
    final location = GoRouterState.of(context).uri.toString();
    final isActive = destination.branchIndex != null
        ? currentIndex == destination.branchIndex
        : location.startsWith(destination.route);
    
    return InkWell(
      onTap: () {
        _handleNavigation(context, navigationShell, destination);
        if (closeDrawerAfterTap && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
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
              destination.icon,
              color: isActive 
                  ? AppColors.primary 
                  : Colors.white, // White icon
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                destination.label,
                style: TextStyle(
                  color: isActive
                      ? AppColors.primary
                      : Colors.white, // White text
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(
    BuildContext context,
    StatefulNavigationShell navigationShell,
    _AdminNavDestination destination,
  ) {
    if (destination.branchIndex != null) {
      context.go(destination.route);
      navigationShell.goBranch(destination.branchIndex!);
      return;
    }

    if (destination.usePushNavigation) {
      context.push(destination.route);
    } else {
      context.go(destination.route);
    }
  }
}

class _AdminNavDestination {
  final IconData icon;
  final String label;
  final String route;
  final int? branchIndex;
  final bool usePushNavigation;

  const _AdminNavDestination({
    required this.icon,
    required this.label,
    required this.route,
    this.branchIndex,
    this.usePushNavigation = false,
  });
}
