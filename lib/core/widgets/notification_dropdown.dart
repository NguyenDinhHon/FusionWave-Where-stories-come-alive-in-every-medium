import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/notification_model.dart';
import '../../features/notifications/presentation/providers/notification_data_provider.dart';
import '../constants/app_colors.dart';

/// Notification dropdown widget - hiển thị thông báo gọn
class NotificationDropdown extends ConsumerWidget {
  const NotificationDropdown({super.key});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.challenge:
        return Icons.emoji_events;
      case NotificationType.achievement:
        return Icons.star;
      case NotificationType.bookUpdate:
        return Icons.book;
      case NotificationType.friendActivity:
        return Icons.people;
      case NotificationType.reminder:
        return Icons.notifications;
      default:
        return Icons.info;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.challenge:
        return Colors.orange;
      case NotificationType.achievement:
        return Colors.amber;
      case NotificationType.bookUpdate:
        return Colors.blue;
      case NotificationType.friendActivity:
        return Colors.green;
      case NotificationType.reminder:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification, WidgetRef ref) {
    // Mark as read
    if (!notification.isRead) {
      ref.read(notificationDataControllerProvider).markAsRead(notification.id);
    }
    
    // Navigate based on type
    if (notification.relatedId != null) {
      switch (notification.type) {
        case NotificationType.challenge:
          context.push('/challenges');
          break;
        case NotificationType.bookUpdate:
          context.push('/book/${notification.relatedId}');
          break;
        default:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(recentNotificationsProvider);
    final unreadCountAsync = ref.watch(unreadCountProvider);
    
    return PopupMenuButton<NotificationModel>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Icon luôn cùng màu, không đổi trong mọi trạng thái
          // Sử dụng Container với Icon để PopupMenuButton tự xử lý sự kiện
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.iconLight, // Màu cố định trong mọi trạng thái
              size: 24,
            ),
          ),
          // Badge đỏ chỉ hiện khi có thông báo chưa đọc
          unreadCountAsync.when(
            data: (count) {
              if (count == 0) return const SizedBox();
              return Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      itemBuilder: (context) {
        return notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return [
                const PopupMenuItem<NotificationModel>(
                  enabled: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Không có thông báo',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<NotificationModel>(
                  value: null,
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/notifications');
                      },
                      child: const Text('Xem tất cả thông báo'),
                    ),
                  ),
                ),
              ];
            }
            
            final items = <PopupMenuEntry<NotificationModel>>[];
            
            // Add notifications
            for (var notification in notifications) {
              items.add(
                PopupMenuItem<NotificationModel>(
                  value: notification,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _handleNotificationTap(context, notification, ref);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: notification.isRead 
                            ? Colors.transparent 
                            : Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getNotificationColor(notification.type).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getNotificationIcon(notification.type),
                              color: _getNotificationColor(notification.type),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontWeight: notification.isRead 
                                        ? FontWeight.normal 
                                        : FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notification.body,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(notification.createdAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8, top: 4),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            
            // Add divider and "See All" button
            items.add(const PopupMenuDivider());
            items.add(
              PopupMenuItem<NotificationModel>(
                value: null,
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/notifications');
                    },
                    child: const Text(
                      'Xem tất cả thông báo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            );
            
            return items;
          },
          loading: () => [
            const PopupMenuItem<NotificationModel>(
              enabled: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
          error: (error, stack) => [
            PopupMenuItem<NotificationModel>(
              enabled: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Lỗi: ${error.toString()}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<NotificationModel>(
              value: null,
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/notifications');
                  },
                  child: const Text('Xem tất cả thông báo'),
                ),
              ),
            ),
          ],
        );
      },
      onSelected: (notification) {
        // Notification tap is handled in PopupMenuItem's InkWell
      },
    );
  }
}

