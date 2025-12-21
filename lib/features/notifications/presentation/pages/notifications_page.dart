import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../data/models/notification_model.dart';
import '../providers/notification_data_provider.dart';

/// Notifications page
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(allNotificationsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          notificationsAsync.when(
            data: (notifications) {
              if (notifications.isEmpty) return const SizedBox();
              return TextButton(
                onPressed: () async {
                  await ref.read(notificationDataControllerProvider).markAllAsRead();
                  ref.invalidate(allNotificationsProvider);
                  ref.invalidate(recentNotificationsProvider);
                  ref.invalidate(unreadCountProvider);
                },
                child: const Text('Mark all as read'),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return EmptyState(
              title: 'No notifications',
              message: 'You\'re all caught up!',
              icon: Icons.notifications_none,
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allNotificationsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildNotificationCard(context, notification, ref),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerListItem(),
        ),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(allNotificationsProvider),
        ),
      ),
    );
  }
  
  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
    WidgetRef ref,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead ? null : Colors.blue.withOpacity(0.05),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              _formatDate(notification.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () async {
          // Mark as read
          if (!notification.isRead) {
            await ref.read(notificationDataControllerProvider).markAsRead(notification.id);
            ref.invalidate(allNotificationsProvider);
            ref.invalidate(recentNotificationsProvider);
            ref.invalidate(unreadCountProvider);
          }
          
          // Navigate based on notification type
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
        },
      ),
    );
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
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      }
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

