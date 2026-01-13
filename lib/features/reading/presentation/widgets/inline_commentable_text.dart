import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/models/comment_model.dart';
import '../../../social/presentation/providers/social_provider.dart';

/// Text widget với inline comments (giống Wattpad)
/// Hiển thị comment count và cho phép tap để xem comments
class InlineCommentableText extends ConsumerWidget {
  final String text;
  final String bookId;
  final String chapterId;
  final TextStyle? textStyle;
  
  const InlineCommentableText({
    super.key,
    required this.text,
    required this.bookId,
    required this.chapterId,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentsByChapterIdProvider(chapterId));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text content với selectable text
        SelectableText(
          text,
          style: textStyle ?? const TextStyle(fontSize: 16),
        ),
        
        // Comment indicator
        commentsAsync.when(
          data: (comments) {
            if (comments.isEmpty) return const SizedBox();
            
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: InkWell(
                onTap: () {
                  context.push('/book/$bookId/comments?chapterId=$chapterId');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.comment, size: 16, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(
                        '${comments.length} ${comments.length == 1 ? 'comment' : 'comments'}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const SizedBox(),
          error: (_, _) => const SizedBox(),
        ),
      ],
    );
  }
}

/// Provider for comments by chapter ID
final commentsByChapterIdProvider = FutureProvider.family<List<CommentModel>, String>((ref, chapterId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getCommentsByChapterId(chapterId);
});

