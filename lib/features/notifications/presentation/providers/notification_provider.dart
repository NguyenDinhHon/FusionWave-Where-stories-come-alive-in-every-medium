import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Notification controller provider
final notificationControllerProvider = Provider<NotificationController>((ref) {
  return NotificationController(ref.read(notificationServiceProvider));
});

class NotificationController {
  final NotificationService _service;
  
  NotificationController(this._service);
  
  Future<void> initialize() => _service.initialize();
  Future<void> scheduleDailyReminder(TimeOfDay time) => _service.scheduleDailyReminder(time);
  Future<void> cancelDailyReminder() => _service.cancelDailyReminder();
  Future<void> showChapterCompleteNotification({
    required String bookTitle,
    required String chapterTitle,
  }) => _service.showChapterCompleteNotification(
    bookTitle: bookTitle,
    chapterTitle: chapterTitle,
  );
  Future<void> showGoalAchievedNotification({
    required String message,
  }) => _service.showGoalAchievedNotification(message: message);
}

