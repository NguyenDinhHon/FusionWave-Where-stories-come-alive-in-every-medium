import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../../data/models/notification_model.dart';

/// Notification repository provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

/// Recent notifications provider (5 notifications for dropdown)
final recentNotificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotifications(limit: 5);
});

/// All notifications provider (for notifications page)
final allNotificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotifications(limit: 100);
});

/// Unread count provider
final unreadCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadCountStream();
});

/// Notification controller provider
final notificationDataControllerProvider = Provider<NotificationDataController>((ref) {
  return NotificationDataController(ref.read(notificationRepositoryProvider));
});

class NotificationDataController {
  final NotificationRepository _repository;
  
  NotificationDataController(this._repository);
  
  Future<void> markAsRead(String notificationId) => 
      _repository.markAsRead(notificationId);
  
  Future<void> markAllAsRead() => 
      _repository.markAllAsRead();
}

