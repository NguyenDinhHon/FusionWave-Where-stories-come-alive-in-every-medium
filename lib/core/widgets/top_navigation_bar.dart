import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'notification_dropdown.dart';
import 'search_overlay.dart';

/// Top Navigation Bar giống Wattpad & Waka
class TopNavigationBar extends ConsumerWidget implements PreferredSizeWidget {
  const TopNavigationBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserModelProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () {
            // Unfocus search bar khi tap vào AppBar (không phải widget con)
            FocusScope.of(context).unfocus();
          },
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // Logo/App Name - compact
                InkWell(
                  onTap: () => context.go('/home'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.menu_book,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'FusionWave',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Right side actions - compact
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search button - mở overlay
                    IconButton(
                      icon: const Icon(Icons.search),
                      color: AppColors.primary,
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.transparent,
                          builder: (context) => const SearchOverlay(),
                        );
                      },
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Notifications dropdown
                    const NotificationDropdown(),

                    const SizedBox(width: 4),

                    // User menu - compact
                    currentUser.when(
                      data: (user) {
                        if (user == null) {
                          return IconButton(
                            icon: const Icon(Icons.person_outline),
                            color: AppColors.primary,
                            onPressed: () => context.go('/login'),
                            iconSize: 24,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          );
                        }

                        return PopupMenuButton<String>(
                          icon: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
                                      fontSize: 14,
                                    ),
                                  )
                                : null,
                          ),
                          offset: const Offset(0, 50),
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
                                ref
                                    .read(authControllerProvider.notifier)
                                    .signOut();
                                context.go('/login');
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'profile',
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    (user.displayName?.isNotEmpty ?? false)
                                        ? user.displayName!
                                        : 'Profile',
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'library',
                              child: Row(
                                children: [
                                  Icon(Icons.library_books, size: 18),
                                  SizedBox(width: 8),
                                  Text('My Library'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'settings',
                              child: Row(
                                children: [
                                  Icon(Icons.settings, size: 18),
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
                                  Icon(
                                    Icons.logout,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Sign Out',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (_, _) => IconButton(
                        icon: const Icon(Icons.person_outline),
                        color: AppColors.primary,
                        onPressed: () => context.go('/login'),
                        iconSize: 24,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
