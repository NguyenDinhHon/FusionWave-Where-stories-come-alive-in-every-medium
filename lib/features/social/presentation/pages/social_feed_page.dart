import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../data/models/activity_model.dart';

/// Social Feed page với recent activity
class SocialFeedPage extends ConsumerStatefulWidget {
  const SocialFeedPage({super.key});

  @override
  ConsumerState<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends ConsumerState<SocialFeedPage> {
  final List<ActivityModel> _activities = [];
  bool _isLoading = false;

  Future<void> _refreshFeed() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading activities
    await Future.delayed(const Duration(seconds: 1));
    
    // ignore: todo
    // TODO: Load activities from provider/repository when implemented
    // For now, just show empty state or existing activities
    
    setState(() {
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feed refreshed'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshFeed,
          ),
        ],
      ),
      body: _activities.isEmpty
          ? RefreshIndicator(
              onRefresh: _refreshFeed,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: const EmptyState(
                    title: 'No activity yet',
                    message: 'Follow friends to see their reading activity',
                    icon: Icons.people_outline,
                  ),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshFeed,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _activities.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildActivityCard(context, _activities[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
  
  Widget _buildActivityCard(BuildContext context, ActivityModel activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: activity.bookId != null
            ? () => context.push('/book/${activity.bookId}')
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User avatar
              CircleAvatar(
                radius: 24,
                backgroundImage: activity.userAvatarUrl != null
                    ? NetworkImage(activity.userAvatarUrl!)
                    : null,
                child: activity.userAvatarUrl == null
                    ? Text(activity.userName[0].toUpperCase())
                    : null,
              ),
              const SizedBox(width: 12),
              
              // Activity content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          TextSpan(
                            text: activity.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ' ${_getActivityText(activity.type)}'),
                          if (activity.bookTitle != null)
                            TextSpan(
                              text: ' ${activity.bookTitle}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),
                    if (activity.content != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          activity.content!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                    if (activity.bookCoverUrl != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            activity.bookCoverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(Icons.book),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(activity.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _getActivityIcon(activity.type),
                color: _getActivityColor(activity.type),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getActivityText(ActivityType type) {
    switch (type) {
      case ActivityType.reading:
        return 'is reading';
      case ActivityType.completed:
        return 'completed';
      case ActivityType.rated:
        return 'rated';
      case ActivityType.commented:
        return 'commented on';
      case ActivityType.bookmarked:
        return 'bookmarked';
      case ActivityType.shared:
        return 'shared';
    }
  }
  
  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.reading:
        return Icons.menu_book;
      case ActivityType.completed:
        return Icons.check_circle;
      case ActivityType.rated:
        return Icons.star;
      case ActivityType.commented:
        return Icons.comment;
      case ActivityType.bookmarked:
        return Icons.bookmark;
      case ActivityType.shared:
        return Icons.share;
    }
  }
  
  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.reading:
        return Colors.blue;
      case ActivityType.completed:
        return Colors.green;
      case ActivityType.rated:
        return Colors.amber;
      case ActivityType.commented:
        return Colors.purple;
      case ActivityType.bookmarked:
        return Colors.red;
      case ActivityType.shared:
        return Colors.teal;
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
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

