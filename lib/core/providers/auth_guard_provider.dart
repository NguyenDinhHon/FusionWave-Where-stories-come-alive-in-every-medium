import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../constants/app_constants.dart';

/// Provider to check if user is authenticated
///
/// Uses FirebaseAuth directly so that authentication is
/// available immediately after sign-in, without waiting
/// for Firestore user data to load.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser != null) return true;

  // Fallback to auth state changes stream in case auth state
  // has not propagated to FirebaseAuth.instance yet.
  final authStateAsync = ref.watch(authStateChangesProvider);
  return authStateAsync.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

/// Provider to check if user is admin
///
/// Prioritises the AuthController state (updated right after sign-in)
/// then falls back to Firestore-backed currentUserModelProvider.
final isAdminProvider = Provider<bool>((ref) {
  // 1) Try from AuthController (fast path right after login)
  final authState = ref.watch(authControllerProvider);
  final controllerUser = authState.value;
  if (controllerUser != null) {
    return controllerUser.role == AppConstants.roleAdmin;
  }

  // 2) Fallback to Firestore user model
  final userAsync = ref.watch(currentUserModelProvider);
  return userAsync.maybeWhen(
    data: (user) => user?.role == AppConstants.roleAdmin,
    orElse: () => false,
  );
});

/// Provider to get current user role
final currentUserRoleProvider = Provider<String?>((ref) {
  // Prefer AuthController (fast)
  final authState = ref.watch(authControllerProvider);
  final controllerUser = authState.value;
  if (controllerUser != null) return controllerUser.role;

  // Fallback to Firestore model
  final userAsync = ref.watch(currentUserModelProvider);
  return userAsync.maybeWhen(
    data: (user) => user?.role,
    orElse: () => null,
  );
});
