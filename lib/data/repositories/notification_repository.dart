import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firebase_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/notification_model.dart';
import '../../core/utils/logger.dart';

/// Notification repository
class NotificationRepository {
  final FirebaseService _firebaseService = FirebaseService();
  
  FirebaseFirestore get _firestore => _firebaseService.firestore;
  String? get _currentUserId => _firebaseService.currentUserId;
  
  // Get user notifications
  Future<List<NotificationModel>> getNotifications({
    int limit = 50,
    bool? unreadOnly,
  }) async {
    try {
      if (_currentUserId == null) {
        // Return empty list for unauthenticated users
        return [];
      }
      
      Query query;
      
      if (unreadOnly == true) {
        // Chỉ filter theo userId và isRead, sort trong memory
        query = _firestore
            .collection(AppConstants.notificationsCollection)
            .where('userId', isEqualTo: _currentUserId)
            .where('isRead', isEqualTo: false)
            .limit(limit * 2); // Lấy nhiều hơn để sort trong memory
      } else {
        // Chỉ filter theo userId, sort trong memory
        query = _firestore
            .collection(AppConstants.notificationsCollection)
            .where('userId', isEqualTo: _currentUserId)
            .limit(limit * 2); // Lấy nhiều hơn để sort trong memory
      }
      
      final snapshot = await query.get();
      
      List<NotificationModel> notifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
      
      // Sort trong memory theo createdAt
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Giới hạn số lượng
      return notifications.take(limit).toList();
    } catch (e) {
      AppLogger.error('Get notifications error', error: e);
      rethrow;
    }
  }
  
  // Get notifications stream (realtime)
  Stream<List<NotificationModel>> getNotificationsStream({int limit = 50}) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: _currentUserId)
        .limit(limit * 2) // Lấy nhiều hơn để sort trong memory
        .snapshots()
        .map((snapshot) {
          List<NotificationModel> notifications = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();
          
          // Sort trong memory theo createdAt
          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          // Giới hạn số lượng
          return notifications.take(limit).toList();
        });
  }
  
  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      await _firestore
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
      
      AppLogger.info('Notification marked as read: $notificationId');
    } catch (e) {
      AppLogger.error('Mark notification as read error', error: e);
      rethrow;
    }
  }
  
  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final snapshot = await _firestore
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: _currentUserId)
          .where('isRead', isEqualTo: false)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
      AppLogger.info('All notifications marked as read');
    } catch (e) {
      AppLogger.error('Mark all notifications as read error', error: e);
      rethrow;
    }
  }
  
  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      if (_currentUserId == null) return 0;
      
      final snapshot = await _firestore
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: _currentUserId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      AppLogger.error('Get unread count error', error: e);
      return 0;
    }
  }
  
  // Get unread count stream
  Stream<int> getUnreadCountStream() {
    if (_currentUserId == null) {
      return Stream.value(0);
    }
    
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: _currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

