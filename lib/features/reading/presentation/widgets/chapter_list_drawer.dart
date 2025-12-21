import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/chapter_model.dart';
import '../providers/reading_provider.dart';
import '../../../home/presentation/providers/book_provider.dart';

/// Chapter list drawer với table of contents
class ChapterListDrawer extends ConsumerWidget {
  final String bookId;
  final int currentChapterNumber;
  final Function(ChapterModel) onChapterSelected;
  
  const ChapterListDrawer({
    super.key,
    required this.bookId,
    required this.currentChapterNumber,
    required this.onChapterSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersByBookIdProvider(bookId));
    final bookAsync = ref.watch(bookByIdProvider(bookId));
    
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Row(
                children: [
                  Icon(Icons.menu_book, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: bookAsync.when(
                      data: (book) => Text(
                        book?.title ?? 'Chapters',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      loading: () => const Text('Loading...'),
                      error: (_, __) => const Text('Chapters'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Chapter list
            Expanded(
              child: chaptersAsync.when(
                data: (chapters) {
                  if (chapters.isEmpty) {
                    return const Center(
                      child: Text('No chapters available'),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      final isCurrentChapter = chapter.chapterNumber == currentChapterNumber;
                      
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isCurrentChapter
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${chapter.chapterNumber}',
                              style: TextStyle(
                                color: isCurrentChapter
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          chapter.title,
                          style: TextStyle(
                            fontWeight: isCurrentChapter
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isCurrentChapter
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                        subtitle: chapter.subtitle != null
                            ? Text(
                                chapter.subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : chapter.estimatedReadingTimeMinutes != null
                                ? Text(
                                    '${chapter.estimatedReadingTimeMinutes} min read',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                : null,
                        trailing: isCurrentChapter
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                        selected: isCurrentChapter,
                        onTap: () {
                          onChapterSelected(chapter);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(chaptersByBookIdProvider(bookId));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

