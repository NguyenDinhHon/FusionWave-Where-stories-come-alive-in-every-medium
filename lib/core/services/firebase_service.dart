import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';  // Will be enabled when added
import '../utils/logger.dart';

/// Centralized Firebase services
class FirebaseService {
  // Singleton instance
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();
  
  // Firebase Services
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;
  FirebaseMessaging get messaging => FirebaseMessaging.instance;
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  // FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;  // Will be enabled when added
  
  // Current User
  User? get currentUser => auth.currentUser;
  String? get currentUserId => currentUser?.uid;
  
  // Initialize Firebase services
  Future<void> initialize() async {
    try {
      // Firestore offline persistence is enabled by default
      // No need to call enablePersistence in newer versions
      
      // Request notification permissions
      await _requestNotificationPermissions();
      
      // Setup FCM token refresh
      _setupFCMTokenRefresh();
      
      // Setup message handlers
      _setupMessageHandlers();
      
      AppLogger.info('Firebase services initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize Firebase services', error: e);
      rethrow;
    }
  }
  
  // Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    try {
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      AppLogger.info('Notification permission status: ${settings.authorizationStatus}');
    } catch (e) {
      AppLogger.error('Failed to request notification permissions', error: e);
    }
  }
  
  // Setup FCM token refresh
  void _setupFCMTokenRefresh() {
    messaging.onTokenRefresh.listen((newToken) {
      AppLogger.info('FCM token refreshed: $newToken');
      if (currentUserId != null) {
        _updateUserFCMToken(newToken);
      }
    });
  }
  
  // Update user FCM token in Firestore
  Future<void> _updateUserFCMToken(String token) async {
    try {
      if (currentUserId == null) return;
      
      await firestore.collection('users').doc(currentUserId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.error('Failed to update FCM token', error: e);
    }
  }
  
  // Setup message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('Foreground message received: ${message.messageId}');
      // Handle foreground notification
    });
    
    // Background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('Background message opened: ${message.messageId}');
      // Handle notification tap
    });
  }
  
  // Get initial FCM token
  Future<String?> getFCMToken() async {
    try {
      return await messaging.getToken();
    } catch (e) {
      AppLogger.error('Failed to get FCM token', error: e);
      return null;
    }
  }
  
  // Log analytics event
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    try {
      await analytics.logEvent(
        name: name,
        parameters: parameters?.map((key, value) => MapEntry(key, value as Object)),
      );
      AppLogger.logEvent(name, parameters);
    } catch (e) {
      AppLogger.error('Failed to log analytics event', error: e);
    }
  }
  
  // Set user properties
  Future<void> setUserProperties({
    String? userId,
    String? userName,
    String? userEmail,
  }) async {
    try {
      await analytics.setUserId(id: userId);
      if (userName != null) {
        await analytics.setUserProperty(name: 'user_name', value: userName);
      }
      if (userEmail != null) {
        await analytics.setUserProperty(name: 'user_email', value: userEmail);
      }
    } catch (e) {
      AppLogger.error('Failed to set user properties', error: e);
    }
  }
}

