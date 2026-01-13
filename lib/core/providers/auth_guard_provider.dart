import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../constants/app_constants.dart';

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserModelProvider);
  return userAsync.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, _) => false,
  );
});

/// Provider to check if user is admin
final isAdminProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserModelProvider);
  return userAsync.when(
    data: (user) => user?.role == AppConstants.roleAdmin,
    loading: () => false,
    error: (_, _) => false,
  );
});

/// Provider to get current user role
final currentUserRoleProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserModelProvider);
  return userAsync.when(
    data: (user) => user?.role,
    loading: () => null,
    error: (_, _) => null,
  );
});
