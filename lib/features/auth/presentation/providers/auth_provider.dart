import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Current user stream provider
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// Current user model provider - uses real-time stream from Firestore
final currentUserModelProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      
      // Use FirebaseService directly to access Firestore
      final firebaseService = FirebaseService();
      final firestore = firebaseService.firestore;
      final usersCollection = AppConstants.usersCollection;
      
      // Return real-time stream from Firestore
      return firestore
          .collection(usersCollection)
          .doc(user.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return null;
            try {
              return UserModel.fromFirestore(doc);
            } catch (e) {
              return null;
            }
          }).handleError((error) {
            // Return null if error (user not found, etc.)
            return null;
          });
    },
    loading: () => Stream.value(null),
    error: (_, _) => Stream.value(null),
  );
});

/// Auth controller provider
final authControllerProvider = NotifierProvider<AuthController, AsyncValue<UserModel?>>(() {
  return AuthController();
});

class AuthController extends Notifier<AsyncValue<UserModel?>> {
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);
  
  @override
  AsyncValue<UserModel?> build() {
    // Listen to auth state changes
    ref.listen(authStateChangesProvider, (previous, next) {
      next.whenData((user) async {
        if (user != null) {
          try {
            final userModel = await _authRepository.getUserData(user.uid);
            state = AsyncValue.data(userModel);
          } catch (e, stack) {
            state = AsyncValue.error(e, stack);
          }
        } else {
          state = const AsyncValue.data(null);
        }
      });
    });
    
    return const AsyncValue.loading();
  }
  
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userModel = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AsyncValue.data(userModel);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userModel = await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AsyncValue.data(userModel);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      await _authRepository.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final userModel = await _authRepository.signInWithGoogle();
      state = AsyncValue.data(userModel);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  Future<void> sendSignInLinkToEmail({
    required String email,
    String? url,
    bool handleCodeInApp = true,
  }) async {
    try {
      await _authRepository.sendSignInLinkToEmail(
        email: email,
        url: url,
        handleCodeInApp: handleCodeInApp,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> signInWithEmailLink({
    required String email,
    required String link,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userModel = await _authRepository.signInWithEmailLink(
        email: email,
        link: link,
      );
      state = AsyncValue.data(userModel);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

