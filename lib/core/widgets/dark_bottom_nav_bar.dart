import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

/// Dark theme Bottom Navigation Bar
class DarkBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const DarkBottomNavBar({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkCard,
        border: Border(top: BorderSide(color: AppColors.darkBorder, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              icon: Icons.auto_stories_outlined,
              activeIcon: Icons.auto_stories,
              label: 'Masterpiece',
              index: 0,
              route: '/home',
            ),
            _buildNavItem(
              context,
              icon: Icons.library_books_outlined,
              activeIcon: Icons.library_books,
              label: 'Library',
              index: 1,
              route: '/library',
            ),
            _buildNavItem(
              context,
              icon: Icons.explore_outlined,
              activeIcon: Icons.explore,
              label: 'Discover',
              index: 2,
              route: '/categories',
            ),
            _buildNavItem(
              context,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'User',
              index: 3,
              route: '/profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required String route,
  }) {
    final isActive = currentIndex == index;

    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!(index);
        } else {
          context.go(route);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? AppColors.actionPrimary
                  : AppColors.darkTextSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? AppColors.actionPrimary
                    : AppColors.darkTextSecondary,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
