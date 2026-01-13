import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../data/models/comment_model.dart';
import '../providers/social_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CommentsPage extends ConsumerStatefulWidget {
  final String bookId;
  final String? chapterId;
  
  const CommentsPage({
    super.key,
    required this.bookId,
    this.chapterId,
  });

  @override
  ConsumerState<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends ConsumerState<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    try {
      final controller = ref.read(socialControllerProvider);
      await controller.addComment(
        bookId: widget.bookId,
        chapterId: widget.chapterId,
        content: _commentController.text.trim(),
      );
      
      _commentController.clear();
      ref.invalidate(commentsByBookIdProvider(widget.bookId));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsByBookIdProvider(widget.bookId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.comments),
      ),
      body: Column(
        children: [
          // Add comment section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
          
          // Comments list
          Expanded(
            child: commentsAsync.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.comment_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No comments yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(commentsByBookIdProvider(widget.bookId));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return _buildCommentCard(context, comments[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommentCard(BuildContext context, CommentModel comment) {
    final currentUser = ref.watch(currentUserModelProvider);
    final isOwnComment = currentUser.maybeWhen(
      data: (user) => user?.id == comment.userId,
      orElse: () => false,
    );
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(comment.userId.substring(0, 1).toUpperCase()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User ${comment.userId.substring(0, 8)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        comment.createdAt.toTimeAgo(),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (isOwnComment)
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () async {
                      // Capture context and messenger before async operations
                      final currentContext = context;
                      final messenger = ScaffoldMessenger.of(currentContext);
                      
                      try {
                        await ref.read(socialControllerProvider).deleteComment(comment.id);
                        ref.invalidate(commentsByBookIdProvider(widget.bookId));
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.content),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    comment.likedBy.contains(currentUser.maybeWhen(
                      data: (user) => user?.id,
                      orElse: () => null,
                    )) ? Icons.favorite : Icons.favorite_border,
                    color: comment.likedBy.contains(currentUser.maybeWhen(
                      data: (user) => user?.id,
                      orElse: () => null,
                    )) ? Colors.red : null,
                  ),
                  onPressed: () {
                    ref.read(socialControllerProvider).toggleCommentLike(comment.id);
                    ref.invalidate(commentsByBookIdProvider(widget.bookId));
                  },
                ),
                Text('${comment.likes}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

