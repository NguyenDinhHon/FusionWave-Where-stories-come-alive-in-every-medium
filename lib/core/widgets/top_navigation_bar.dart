import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'notification_dropdown.dart';
import 'expandable_search_bar.dart';
import 'interactive_button.dart';

/// Top Navigation Bar giống Wattpad & Waka
class TopNavigationBar extends ConsumerWidget implements PreferredSizeWidget {
  const TopNavigationBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);
  
  String _getCurrentRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    // Map routes to navigation items
    if (location == '/home' || location == '/') return '/home';
    if (location == '/library') return '/library';
    if (location == '/categories' || location.startsWith('/categories')) return '/categories';
    if (location == '/recommendations' || location.startsWith('/recommendations')) return '/recommendations';
    return location;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserModelProvider);
    final currentRoute = _getCurrentRoute(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Logo/App Name
              InkWell(
                onTap: () => context.go('/home'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.appName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Navigation Menu Items - Only show on larger screens
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Hide navigation items on small screens (< 600px)
                    if (constraints.maxWidth < 400) {
                      return const SizedBox();
                    }
                    
                    // Show condensed on medium screens
                    final showLabels = constraints.maxWidth > 500;
                    
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildNavItem(
                            context,
                            label: showLabels ? 'Home' : '',
                            icon: Icons.home,
                            route: '/home',
                            isActive: currentRoute == '/home' || currentRoute == '/',
                          ),
                          const SizedBox(width: 4),
                          _buildNavItem(
                            context,
                            label: showLabels ? 'Library' : '',
                            icon: Icons.library_books,
                            route: '/library',
                            isActive: currentRoute == '/library',
                          ),
                          const SizedBox(width: 4),
                          if (constraints.maxWidth > 450)
                            _buildCategoryDropdown(context, currentRoute),
                          const SizedBox(width: 4),
                          _buildNavItem(
                            context,
                            label: showLabels ? 'Trending' : '',
                            icon: Icons.trending_up,
                            route: '/recommendations',
                            isActive: currentRoute == '/recommendations' || currentRoute.startsWith('/recommendations'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Right side actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Expandable search bar
                  const ExpandableSearchBar(),
                  
                  const SizedBox(width: 8),
                  
                  // Notifications dropdown
                  const NotificationDropdown(),
                  
                  // User menu
                  currentUser.when(
                    data: (user) {
                      if (user == null) {
                        return InteractiveButton(
                          label: 'Sign In',
                          onPressed: () => context.go('/login'),
                          isOutlined: true,
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          textColor: AppColors.primary,
                          iconColor: AppColors.primary,
                        );
                      }
                      
                      return PopupMenuButton<String>(
                        icon: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Text(
                                  (user.displayName?.isNotEmpty ?? false)
                                      ? user.displayName![0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'profile':
                              context.go('/profile');
                              break;
                            case 'library':
                              context.go('/library');
                              break;
                            case 'settings':
                              context.go('/settings');
                              break;
                            case 'logout':
                              ref.read(authControllerProvider.notifier).signOut();
                              context.go('/login');
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'profile',
                            child: Row(
                              children: [
                                const Icon(Icons.person, size: 20),
                                const SizedBox(width: 8),
                                Text((user.displayName?.isNotEmpty ?? false)
                                    ? user.displayName!
                                    : 'Profile'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'library',
                            child: Row(
                              children: [
                                Icon(Icons.library_books, size: 20),
                                SizedBox(width: 8),
                                Text('My Library'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'settings',
                            child: Row(
                              children: [
                                Icon(Icons.settings, size: 20),
                                SizedBox(width: 8),
                                Text('Settings'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Sign Out', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => InteractiveButton(
                      label: 'Sign In',
                      onPressed: () => context.go('/login'),
                      isOutlined: true,
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      textColor: AppColors.primary,
                      iconColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String route,
    required bool isActive,
  }) {
    return InteractiveButton(
      label: label,
      icon: icon,
      onPressed: () => context.go(route),
      backgroundColor: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
      textColor: isActive ? AppColors.primary : AppColors.iconLight,
      iconColor: isActive ? AppColors.primary : AppColors.iconLight,
      isOutlined: false,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 8,
      elevation: 0,
    );
  }
  
  Widget _buildCategoryDropdown(BuildContext context, String currentRoute) {
    final isActive = currentRoute == '/categories' || currentRoute.startsWith('/categories');
    
    final categories = [
      {'name': 'All Categories', 'route': '/categories', 'icon': Icons.apps},
      {'name': 'Fiction', 'route': '/categories?category=Fiction', 'icon': Icons.book},
      {'name': 'Non-Fiction', 'route': '/categories?category=Non-Fiction', 'icon': Icons.article},
      {'name': 'Science', 'route': '/categories?category=Science', 'icon': Icons.science},
      {'name': 'History', 'route': '/categories?category=History', 'icon': Icons.history},
      {'name': 'Biography', 'route': '/categories?category=Biography', 'icon': Icons.person},
      {'name': 'Fantasy', 'route': '/categories?category=Fantasy', 'icon': Icons.auto_stories},
      {'name': 'Mystery', 'route': '/categories?category=Mystery', 'icon': Icons.search},
      {'name': 'Romance', 'route': '/categories?category=Romance', 'icon': Icons.favorite},
      {'name': 'Thriller', 'route': '/categories?category=Thriller', 'icon': Icons.movie},
    ];
    
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.explore,
              size: 20,
              color: isActive ? AppColors.primary : AppColors.iconLight,
            ),
            const SizedBox(width: 6),
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.iconLight,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: isActive ? AppColors.primary : AppColors.iconLight,
            ),
          ],
        ),
      ),
      onSelected: (value) {
        context.go(value);
      },
      itemBuilder: (context) => categories.map((category) {
        return PopupMenuItem<String>(
          value: category['route'] as String,
          child: Row(
            children: [
              Icon(
                category['icon'] as IconData,
                size: 20,
                color: AppColors.iconLight,
              ),
              const SizedBox(width: 12),
              Text(
                category['name'] as String,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

