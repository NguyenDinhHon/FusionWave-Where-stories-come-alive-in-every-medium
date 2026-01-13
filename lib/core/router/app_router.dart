import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_guard_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../constants/app_constants.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/library/presentation/pages/library_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/seed_user_data_page.dart';
import '../../features/reading/presentation/pages/reading_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/book/presentation/pages/book_detail_page.dart';
import '../../features/social/presentation/pages/comments_page.dart';
import '../../features/social/presentation/pages/leaderboard_page.dart';
import '../../features/admin/presentation/pages/seed_data_page.dart';
import '../../features/admin/presentation/pages/comprehensive_seed_data_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/upload_book_page.dart';
import '../../features/admin/presentation/pages/manage_books_page.dart';
import '../../features/admin/presentation/pages/manage_chapters_page.dart';
import '../../features/admin/presentation/pages/edit_book_page.dart';
import '../../features/admin/presentation/pages/edit_chapter_page.dart';
import '../../features/admin/presentation/pages/manage_users_page.dart';
import '../../features/admin/presentation/pages/manage_comments_page.dart';
import '../../features/admin/presentation/pages/manage_categories_page.dart';
import '../../features/admin/presentation/pages/system_settings_page.dart';
import '../../features/auth/presentation/pages/email_link_verify_page.dart';
import '../../features/bookmark/presentation/pages/bookmarks_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/history/presentation/pages/reading_history_page.dart';
import '../../features/stats/presentation/pages/enhanced_stats_page.dart';
import '../../features/collections/presentation/pages/collections_page.dart';
import '../../features/collections/presentation/pages/widgets/collection_detail_page.dart';
import '../../features/challenges/presentation/pages/challenges_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/social/presentation/pages/social_feed_page.dart';
import '../../features/recommendations/presentation/pages/enhanced_recommendations_page.dart';
import '../../features/offline/presentation/pages/offline_books_page.dart';
import '../../features/info/presentation/pages/premium_page.dart';
import '../../features/info/presentation/pages/terms_page.dart';
import '../../features/info/presentation/pages/privacy_page.dart';
import '../../features/info/presentation/pages/payment_policy_page.dart';
import '../../features/info/presentation/pages/help_page.dart';
import '../../features/info/presentation/pages/brand_partnerships_page.dart';
import '../../features/info/presentation/pages/jobs_page.dart';
import '../../features/info/presentation/pages/press_page.dart';
import 'page_transitions.dart';
import 'shell_scaffold.dart';
import 'admin_shell_scaffold.dart';

/// Application routing configuration
class AppRouter {
  // Protected routes that require authentication
  static const List<String> _protectedRoutes = [
    '/library',
    '/profile',
    '/settings',
    '/stats',
    '/leaderboard',
    '/recommendations',
    '/reading',
    '/book',
  ];

  // Auth routes that should redirect to home if already logged in
  static const List<String> _authRoutes = ['/login', '/register'];

  // Admin guard function
  static String? _adminGuard(BuildContext context, GoRouterState state) {
    try {
      final container = ProviderScope.containerOf(context);
      final isAdmin = container.read(isAdminProvider);
      final isAuthenticated = container.read(isAuthenticatedProvider);

      if (!isAuthenticated) {
        return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
      }

      if (!isAdmin) {
        // Show error message and redirect to home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn không có quyền truy cập trang này'),
            backgroundColor: Colors.red,
          ),
        );
        return '/home';
      }

      return null; // Allow access
    } catch (e) {
      // If provider is not available, check Firebase Auth directly
      final isAuthenticated = FirebaseAuth.instance.currentUser != null;
      if (!isAuthenticated) {
        return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
      }
      // For now, allow access if authenticated (will be checked in page)
      return null;
    }
  }

  static String? _redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = FirebaseAuth.instance.currentUser != null;
    final isAuthRoute = _authRoutes.contains(state.uri.path);
    final isProtectedRoute = _protectedRoutes.any(
      (route) => state.uri.path.startsWith(route),
    );

    // Check if user is admin (only if authenticated)
    bool isAdmin = false;
    if (isAuthenticated) {
      try {
        final container = ProviderScope.containerOf(context);
        // First try to get from authController (faster, already updated after sign in)
        final authState = container.read(authControllerProvider);
        final userFromAuth = authState.value;
        if (userFromAuth != null) {
          isAdmin = userFromAuth.role == AppConstants.roleAdmin;
        } else {
          // Fallback to isAdminProvider
          isAdmin = container.read(isAdminProvider);
        }
      } catch (e) {
        // Provider not available yet, will be checked in route
      }
    }

    // Admin routes are handled by _adminGuard (called in route redirect)
    // Exception: seed-data routes don't require admin (for development)
    if (state.uri.path.startsWith('/admin')) {
      if (state.uri.path == '/admin/seed-data' ||
          state.uri.path == '/admin/comprehensive-seed-data') {
        // Allow seed routes if authenticated (no admin check)
        if (!isAuthenticated) {
          return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
        }
        return null; // Allow access
      }
      return _adminGuard(context, state);
    }

    // Allow email link verification route
    if (state.uri.path == '/verify-email-link') {
      return null;
    }

    // If user is authenticated and trying to access auth routes
    if (isAuthenticated && isAuthRoute) {
      // Redirect admin to admin panel, regular users to home
      if (isAdmin) {
        return '/admin';
      }
      return '/home';
    }

    // If user is not authenticated and trying to access protected routes, redirect to login
    if (!isAuthenticated && isProtectedRoute) {
      return '/login';
    }

    // If admin tries to access regular routes (home, library, etc), redirect to admin panel
    if (isAuthenticated && isAdmin && (isProtectedRoute || state.uri.path == '/home' || state.uri.path == '/')) {
      return '/admin';
    }

    // Allow access
    return null;
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      // Check if user is authenticated and admin, redirect to admin panel
      final isAuthenticated = FirebaseAuth.instance.currentUser != null;
      if (isAuthenticated && (state.uri.path == '/home' || state.uri.path == '/')) {
        try {
          final container = ProviderScope.containerOf(context);
          // First try to get from authController (faster, already updated after sign in)
          final authState = container.read(authControllerProvider);
          final userFromAuth = authState.value;
          bool isAdmin = false;
          if (userFromAuth != null) {
            isAdmin = userFromAuth.role == AppConstants.roleAdmin;
          } else {
            // Fallback to isAdminProvider
            isAdmin = container.read(isAdminProvider);
          }
          if (isAdmin) {
            return '/admin';
          }
        } catch (e) {
          // Provider not ready yet, continue with normal redirect
        }
      }
      return _redirect(context, state);
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/verify-email-link',
        name: 'verify-email-link',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          final link = state.uri.toString();
          return EmailLinkVerifyPage(email: email, link: link);
        },
      ),

      // Main Shell Route - preserves navigation stack for main tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home (Masterpiece)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                pageBuilder: (context, state) => PageTransitions.fadeTransition(
                  child: const HomePage(),
                  name: state.name,
                ),
              ),
            ],
          ),

          // Branch 1: Library
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                name: 'library',
                pageBuilder: (context, state) =>
                    PageTransitions.slideFadeTransition(
                      child: const LibraryPage(),
                      name: state.name,
                    ),
              ),
            ],
          ),

          // Branch 2: Discover (Categories)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                name: 'categories',
                pageBuilder: (context, state) {
                  final category = state.uri.queryParameters['category'];
                  return PageTransitions.slideTransition(
                    child: CategoriesPage(initialCategory: category),
                    name: state.name,
                    begin: const Offset(0.0, -1.0),
                  );
                },
              ),
            ],
          ),

          // Branch 3: User (Profile)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (context, state) =>
                    PageTransitions.slideFadeTransition(
                      child: const ProfilePage(),
                      name: state.name,
                    ),
              ),
            ],
          ),
        ],
      ),

      // Other Routes (outside shell - full screen)
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
          child: const EditProfilePage(),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/seed-user-data',
        name: 'seed-user-data',
        pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
          child: const SeedUserDataPage(),
          name: state.name,
        ),
      ),

      GoRoute(
        path: '/search',
        name: 'search',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          child: const SearchPage(),
          name: state.name,
          begin: const Offset(0.0, -1.0),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          child: const SettingsPage(),
          name: state.name,
          begin: const Offset(1.0, 0.0),
        ),
      ),
      GoRoute(
        path: '/stats',
        name: 'stats',
        pageBuilder: (context, state) => PageTransitions.fadeTransition(
          child: const EnhancedStatsPage(),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        pageBuilder: (context, state) => PageTransitions.scaleTransition(
          child: const LeaderboardPage(),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/recommendations',
        name: 'recommendations',
        pageBuilder: (context, state) => PageTransitions.scaleTransition(
          child: const EnhancedRecommendationsPage(),
          name: state.name,
        ),
      ),

      // Social Feed Routes
      GoRoute(
        path: '/social-feed',
        name: 'social-feed',
        pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
          child: const SocialFeedPage(),
          name: state.name,
        ),
      ),

      // Admin Shell Route - Separate admin interface
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Admin Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                name: 'admin',
                redirect: (context, state) => _adminGuard(context, state),
                pageBuilder: (context, state) => PageTransitions.fadeTransition(
                  child: const AdminDashboardPage(),
                  name: state.name,
                ),
              ),
            ],
          ),
          // Branch 1: Manage Books
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/manage-books',
                name: 'manage-books',
                redirect: (context, state) => _adminGuard(context, state),
                pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
                  child: const ManageBooksPage(),
                  name: state.name,
                ),
              ),
            ],
          ),
          // Branch 2: Manage Chapters
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/manage-chapters',
                name: 'manage-chapters',
                redirect: (context, state) => _adminGuard(context, state),
                pageBuilder: (context, state) {
                  final bookId = state.uri.queryParameters['bookId'];
                  return PageTransitions.slideFadeTransition(
                    child: ManageChaptersPage(bookId: bookId),
                    name: state.name,
                  );
                },
              ),
            ],
          ),
          // Branch 3: Manage Users
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/manage-users',
                name: 'manage-users',
                redirect: (context, state) => _adminGuard(context, state),
                pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
                  child: const ManageUsersPage(),
                  name: state.name,
                ),
              ),
            ],
          ),
          // Branch 4: Manage Comments
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/manage-comments',
                name: 'manage-comments',
                redirect: (context, state) => _adminGuard(context, state),
                pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
                  child: const ManageCommentsPage(),
                  name: state.name,
                ),
              ),
            ],
          ),
          // Branch 5: Manage Categories
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/manage-categories',
                name: 'manage-categories',
                redirect: (context, state) => _adminGuard(context, state),
                pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
                  child: const ManageCategoriesPage(),
                  name: state.name,
                ),
              ),
            ],
          ),
          // Branch 6: System Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/system-settings',
                name: 'system-settings',
                redirect: (context, state) => _adminGuard(context, state),
                pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
                  child: const SystemSettingsPage(),
                  name: state.name,
                ),
              ),
            ],
          ),
        ],
      ),

      // Admin Routes (Outside shell - full screen)
      GoRoute(
        path: '/admin/seed-data',
        name: 'seed-data',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          child: const SeedDataPage(),
          name: state.name,
          begin: const Offset(0.0, 1.0),
        ),
      ),
      GoRoute(
        path: '/admin/comprehensive-seed-data',
        name: 'comprehensive-seed-data',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          child: const ComprehensiveSeedDataPage(),
          name: state.name,
          begin: const Offset(0.0, 1.0),
        ),
      ),
      GoRoute(
        path: '/admin/upload-book',
        name: 'upload-book',
        redirect: (context, state) => _adminGuard(context, state),
        pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
          child: const UploadBookPage(),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/admin/edit-book/:bookId',
        name: 'edit-book',
        redirect: (context, state) => _adminGuard(context, state),
        pageBuilder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          return PageTransitions.slideFadeTransition(
            child: EditBookPage(bookId: bookId),
            name: state.name,
          );
        },
      ),
      GoRoute(
        path: '/admin/edit-chapter',
        name: 'edit-chapter',
        redirect: (context, state) => _adminGuard(context, state),
        pageBuilder: (context, state) {
          final bookId = state.uri.queryParameters['bookId']!;
          final chapterId = state.uri.queryParameters['chapterId'];
          return PageTransitions.slideFadeTransition(
            child: EditChapterPage(bookId: bookId, chapterId: chapterId),
            name: state.name,
          );
        },
      ),

      // Bookmark Routes
      GoRoute(
        path: '/bookmarks',
        name: 'bookmarks',
        pageBuilder: (context, state) {
          final bookId = state.uri.queryParameters['bookId'];
          return PageTransitions.slideFadeTransition(
            child: BookmarksPage(bookId: bookId),
            name: state.name,
          );
        },
      ),

      // Notes Routes
      GoRoute(
        path: '/notes',
        name: 'notes',
        pageBuilder: (context, state) {
          final bookId = state.uri.queryParameters['bookId'];
          final chapterId = state.uri.queryParameters['chapterId'];
          return PageTransitions.slideFadeTransition(
            child: NotesPage(bookId: bookId, chapterId: chapterId),
            name: state.name,
          );
        },
      ),

      // Goals Routes
      GoRoute(
        path: '/goals',
        name: 'goals',
        pageBuilder: (context, state) => PageTransitions.scaleTransition(
          child: const GoalsPage(),
          name: state.name,
        ),
      ),

      // History Routes
      GoRoute(
        path: '/history',
        name: 'history',
        pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
          child: const ReadingHistoryPage(),
          name: state.name,
        ),
      ),

      // Collections Routes
      GoRoute(
        path: '/collections',
        name: 'collections',
        pageBuilder: (context, state) => PageTransitions.scaleTransition(
          child: const CollectionsPage(),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/collections/:collectionId',
        name: 'collection-detail',
        pageBuilder: (context, state) {
          final collectionId = state.pathParameters['collectionId']!;
          return PageTransitions.slideFadeTransition(
            child: CollectionDetailPage(collectionId: collectionId),
            name: state.name,
          );
        },
      ),

      // Challenges Routes
      GoRoute(
        path: '/challenges',
        name: 'challenges',
        pageBuilder: (context, state) => PageTransitions.scaleTransition(
          child: const ChallengesPage(),
          name: state.name,
        ),
      ),

      // Notifications Routes
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          child: const NotificationsPage(),
          name: state.name,
          begin: const Offset(1.0, 0.0),
        ),
      ),

      // Offline Routes
      GoRoute(
        path: '/offline',
        name: 'offline',
        pageBuilder: (context, state) => PageTransitions.fadeTransition(
          child: const OfflineBooksPage(),
          name: state.name,
        ),
      ),

      // Book Routes
      GoRoute(
        path: '/book/:bookId',
        name: 'book',
        pageBuilder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          return PageTransitions.slideFadeTransition(
            child: BookDetailPage(bookId: bookId),
            name: state.name,
          );
        },
        routes: [
          GoRoute(
            path: 'comments',
            name: 'book-comments',
            builder: (context, state) {
              final bookId = state.pathParameters['bookId']!;
              return CommentsPage(bookId: bookId);
            },
          ),
        ],
      ),

      // Reading Routes
      GoRoute(
        path: '/reading/:bookId',
        name: 'reading',
        pageBuilder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          final chapterId = state.uri.queryParameters['chapterId'];
          return PageTransitions.slideTransition(
            child: ReadingPage(bookId: bookId, chapterId: chapterId),
            name: state.name,
          );
        },
      ),

      // Info Routes
      GoRoute(
        path: '/premium',
        name: 'premium',
        pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
          child: const PremiumPage(),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
          child: const TermsPage(),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
          child: const PrivacyPage(),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/payment-policy',
        name: 'payment-policy',
        pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
          child: const PaymentPolicyPage(),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
          child: const HelpPage(),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/brand-partnerships',
        name: 'brand-partnerships',
        pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
          child: const BrandPartnershipsPage(),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/jobs',
        name: 'jobs',
        pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
          child: const JobsPage(),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/press',
        name: 'press',
        pageBuilder: (context, state) => PageTransitions.slideFadeTransition(
          child: const PressPage(),
          name: state.name,
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
