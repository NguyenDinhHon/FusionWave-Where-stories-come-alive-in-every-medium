import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/services/firebase_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../../core/utils/logger.dart';

/// Authentication repository
class AuthRepository {
  final FirebaseService _firebaseService = FirebaseService();
  
  FirebaseAuth get _auth => _firebaseService.auth;
  FirebaseFirestore get _firestore => _firebaseService.firestore;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('User credential is null');
      }
      
      // Update last login
      await _updateLastLogin(userCredential.user!.uid);
      
      // Get user data from Firestore
      final userModel = await getUserData(userCredential.user!.uid);
      
      AppLogger.info('User signed in: ${userCredential.user!.email}');
      return userModel;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Sign in failed', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Sign in error', error: e);
      rethrow;
    }
  }
  
  // Register with email and password
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('User credential is null');
      }
      
      // Update display name
      await userCredential.user!.updateDisplayName(displayName);
      
      // Create user document in Firestore
      final userModel = UserModel(
        id: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        role: AppConstants.roleUser,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .set(userModel.toFirestore());
      
      // Get FCM token and update
      final fcmToken = await _firebaseService.getFCMToken();
      if (fcmToken != null) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .update({'fcmToken': fcmToken});
      }
      
      AppLogger.info('User registered: $email');
      return userModel;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Registration failed', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Registration error', error: e);
      rethrow;
    }
  }
  
  // Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      // For web platform, we need to get clientId from firebase_options
      // For other platforms, clientId is not required
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // Web client ID is set via meta tag in web/index.html
        // For other platforms, this is not needed
      );
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        throw Exception('Google sign in was cancelled');
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw Exception('User credential is null');
      }
      
      final user = userCredential.user!;
      
      // Check if user document exists in Firestore
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      
      UserModel userModel;
      
      if (!userDoc.exists) {
        // Create new user document
        userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'User',
          photoUrl: user.photoURL,
          role: AppConstants.roleUser,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toFirestore());
        
        AppLogger.info('New Google user registered: ${user.email}');
      } else {
        // Update last login
        await _updateLastLogin(user.uid);
        
        // Get existing user data
        userModel = UserModel.fromFirestore(userDoc);
        
        // Update photo URL if changed
        if (user.photoURL != null && userModel.photoUrl != user.photoURL) {
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .update({'photoUrl': user.photoURL});
          userModel = userModel.copyWith(photoUrl: user.photoURL);
        }
        
        AppLogger.info('Google user signed in: ${user.email}');
      }
      
      // Get FCM token and update
      final fcmToken = await _firebaseService.getFCMToken();
      if (fcmToken != null) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update({'fcmToken': fcmToken});
      }
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Google sign in failed', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Google sign in error', error: e);
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      AppLogger.info('User signed out');
    } catch (e) {
      AppLogger.error('Sign out error', error: e);
      rethrow;
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      AppLogger.info('Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Password reset failed', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Password reset error', error: e);
      rethrow;
    }
  }
  
  // Send sign-in link to email (passwordless)
  Future<void> sendSignInLinkToEmail({
    required String email,
    String? url,
    bool handleCodeInApp = true,
  }) async {
    try {
      // Use provided URL or construct default URL
      // For web, use current origin + verify-email-link route
      String redirectUrl;
      if (url != null) {
        // Extract base URL from provided URL
        final uri = Uri.parse(url);
        redirectUrl = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}/verify-email-link';
      } else {
        // Default to Firebase hosting URL or localhost for development
        redirectUrl = 'http://localhost:3000/verify-email-link';
      }
      
      final actionCodeSettings = ActionCodeSettings(
        url: redirectUrl,
        handleCodeInApp: handleCodeInApp,
        androidPackageName: null,
        iOSBundleId: null,
      );
      
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
      
      AppLogger.info('Sign-in link sent to: $email');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Send sign-in link failed', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Send sign-in link error', error: e);
      rethrow;
    }
  }
  
  // Sign in with email link
  Future<UserModel> signInWithEmailLink({
    required String email,
    required String link,
  }) async {
    try {
      // Verify the link is valid
      if (!_auth.isSignInWithEmailLink(link)) {
        throw Exception('Invalid email link');
      }
      
      // Sign in with the link
      final userCredential = await _auth.signInWithEmailLink(
        email: email,
        emailLink: link,
      );
      
      if (userCredential.user == null) {
        throw Exception('User credential is null');
      }
      
      final user = userCredential.user!;
      
      // Check if user document exists in Firestore
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      
      UserModel userModel;
      
      if (!userDoc.exists) {
        // Create new user document
        userModel = UserModel(
          id: user.uid,
          email: user.email ?? email,
          displayName: user.displayName ?? email.split('@')[0],
          photoUrl: user.photoURL,
          role: AppConstants.roleUser,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toFirestore());
        
        AppLogger.info('New email link user registered: $email');
      } else {
        // Update last login
        await _updateLastLogin(user.uid);
        
        // Get existing user data
        userModel = UserModel.fromFirestore(userDoc);
        
        AppLogger.info('Email link user signed in: $email');
      }
      
      // Get FCM token and update
      final fcmToken = await _firebaseService.getFCMToken();
      if (fcmToken != null) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update({'fcmToken': fcmToken});
      }
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Sign in with email link failed', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Sign in with email link error', error: e);
      rethrow;
    }
  }
  
  // Get user data from Firestore
  Future<UserModel> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (!doc.exists) {
        throw Exception('User document not found');
      }
      
      return UserModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.error('Get user data error', error: e);
      rethrow;
    }
  }
  
  // Update user data
  Future<void> updateUserData(UserModel userModel) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userModel.id)
          .update(userModel.toFirestore());
      
      AppLogger.info('User data updated: ${userModel.id}');
    } catch (e) {
      AppLogger.error('Update user data error', error: e);
      rethrow;
    }
  }
  
  // Update profile (displayName and photoUrl)
  Future<UserModel> updateProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        throw Exception('User not authenticated');
      }
      
      // Update Firebase Auth profile
      if (displayName != null && displayName != user.displayName) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }
      
      if (photoUrl != null && photoUrl != user.photoURL) {
        await user.updatePhotoURL(photoUrl);
        await user.reload();
      }
      
      // Update Firestore
      final updateData = <String, dynamic>{};
      if (displayName != null) {
        updateData['displayName'] = displayName;
      }
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }
      
      if (updateData.isNotEmpty) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .update(updateData);
      }
      
      // Get updated user data
      final updatedUserModel = await getUserData(userId);
      
      AppLogger.info('Profile updated: $userId');
      return updatedUserModel;
    } catch (e) {
      AppLogger.error('Update profile error', error: e);
      rethrow;
    }
  }
  
  // Upload profile photo to Firebase Storage
  Future<String> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      final storage = _firebaseService.storage;
      final ref = storage.ref().child('profile_photos/$userId.jpg');
      
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      
      AppLogger.info('Profile photo uploaded: $userId');
      return downloadUrl;
    } catch (e) {
      AppLogger.error('Upload profile photo error', error: e);
      rethrow;
    }
  }
  
  // Update last login timestamp
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.error('Update last login error', error: e);
    }
  }
  
  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'invalid-action-code':
        return 'The action code is invalid or expired.';
      case 'expired-action-code':
        return 'The action code has expired.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
  
  // Check if link is a sign-in link
  bool isSignInWithEmailLink(String link) {
    return _auth.isSignInWithEmailLink(link);
  }
}

