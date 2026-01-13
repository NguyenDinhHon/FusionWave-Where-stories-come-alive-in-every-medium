import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';

/// Notification service
class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FlutterRingtonePlayer _ringtonePlayer = FlutterRingtonePlayer();
  
  bool _isInitialized = false;
  
  // Initialize notifications
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      // Request permissions
      await _requestPermissions();
      
      // Setup FCM message handlers
      _setupFCMHandlers();
      
      _isInitialized = true;
      AppLogger.info('Notification service initialized');
    } catch (e) {
      AppLogger.error('Initialize notification service error', error: e);
      rethrow;
    }
  }
  
  // Request permissions
  Future<void> _requestPermissions() async {
    try {
      // Android 13+
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      // iOS
      await _localNotifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (e) {
      AppLogger.error('Request permissions error', error: e);
    }
  }
  
  // Setup FCM handlers
  void _setupFCMHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
      _playNotificationSound(message);
    });
    
    // Background message opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
  }
  
  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'fusionwave_channel',
        'FusionWave Notifications',
        channelDescription: 'Notifications for FusionWave Reader',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const iosDetails = DarwinNotificationDetails();
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? 'FusionWave',
        message.notification?.body ?? '',
        notificationDetails,
      );
    } catch (e) {
      AppLogger.error('Show local notification error', error: e);
    }
  }
  
  // Play notification sound
  Future<void> _playNotificationSound(RemoteMessage message) async {
    try {
      final notificationType = message.data['type'] as String?;
      
      switch (notificationType) {
        case 'chapter_complete':
          await _ringtonePlayer.playNotification(
            asAlarm: false,
            volume: 0.5,
          );
          break;
        case 'daily_reminder':
          await _ringtonePlayer.playNotification(
            asAlarm: false,
            volume: 0.3,
          );
          break;
        case 'goal_achieved':
          await _ringtonePlayer.play(
            fromAsset: 'assets/sounds/success.mp3',
            volume: 0.5,
          );
          break;
        default:
          await _ringtonePlayer.playNotification(
            asAlarm: false,
            volume: 0.3,
          );
      }
    } catch (e) {
      AppLogger.error('Play notification sound error', error: e);
    }
  }
  
  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    try {
      final type = message.data['type'] as String?;
      // final bookId = message.data['bookId'] as String?;
      // final chapterId = message.data['chapterId'] as String?;
      
      // ignore: todo
      // TODO: Navigate based on notification type - requires router context
      AppLogger.info('Notification tapped: $type');
    } catch (e) {
      AppLogger.error('Handle notification tap error', error: e);
    }
  }
  
  // Notification tap callback
  void _onNotificationTapped(NotificationResponse response) {
    // ignore: todo
    // TODO: Handle notification tap - requires router context
    AppLogger.info('Local notification tapped: ${response.payload}');
  }
  
  // Schedule daily reading reminder
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'fusionwave_reminder',
        'Daily Reading Reminder',
        channelDescription: 'Daily reminder to read',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const iosDetails = DarwinNotificationDetails();
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.periodicallyShow(
        0,
        'Time to Read! 📚',
        'Don\'t forget to read today. Continue your reading streak!',
        RepeatInterval.daily,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      
      AppLogger.info('Daily reminder scheduled for ${time.hour}:${time.minute}');
    } catch (e) {
      AppLogger.error('Schedule daily reminder error', error: e);
      rethrow;
    }
  }
  
  // Cancel daily reminder
  Future<void> cancelDailyReminder() async {
    try {
      await _localNotifications.cancel(0);
      AppLogger.info('Daily reminder cancelled');
    } catch (e) {
      AppLogger.error('Cancel daily reminder error', error: e);
    }
  }
  
  // Show chapter completion notification
  Future<void> showChapterCompleteNotification({
    required String bookTitle,
    required String chapterTitle,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'fusionwave_chapter',
        'Chapter Complete',
        channelDescription: 'Chapter completion notifications',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const iosDetails = DarwinNotificationDetails();
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.show(
        AppConstants.chapterCompleteId.hashCode,
        'Chapter Complete! 🎉',
        '$chapterTitle completed in $bookTitle',
        notificationDetails,
      );
      
      // Play success sound
      await _ringtonePlayer.playNotification(
        asAlarm: false,
        volume: 0.5,
      );
    } catch (e) {
      AppLogger.error('Show chapter complete notification error', error: e);
    }
  }
  
  // Show goal achieved notification
  Future<void> showGoalAchievedNotification({
    required String message,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'fusionwave_goal',
        'Goal Achieved',
        channelDescription: 'Reading goal achievement notifications',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const iosDetails = DarwinNotificationDetails();
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.show(
        AppConstants.goalAchievedId.hashCode,
        'Goal Achieved! 🏆',
        message,
        notificationDetails,
      );
      
      // Play success sound
      await _ringtonePlayer.playNotification(
        asAlarm: false,
        volume: 0.6,
      );
    } catch (e) {
      AppLogger.error('Show goal achieved notification error', error: e);
    }
  }
}

