import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../providers/note_provider.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../data/models/note_model.dart';

/// Notes list page
class NotesPage extends ConsumerWidget {
  final String? bookId;
  final String? chapterId;
  
  const NotesPage({
    super.key,
    this.bookId,
    this.chapterId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = chapterId != null
        ? ref.watch(notesByChapterIdProvider(chapterId!))
        : bookId != null
            ? ref.watch(notesByBookIdProvider(bookId!))
            : ref.watch(userNotesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          chapterId != null
              ? 'Chapter Notes'
              : bookId != null
                  ? 'Book Notes'
                  : 'My Notes',
        ),
        actions: [
          if (bookId != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _exportNotes(context, ref, bookId!),
            ),
        ],
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return EmptyState(
              title: 'No notes yet',
              message: chapterId != null
                  ? 'Highlight text while reading to add notes'
                  : bookId != null
                      ? 'Add notes while reading to see them here'
                      : 'Start reading and add notes to save your thoughts',
              icon: Icons.note_outlined,
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return _buildNoteCard(context, ref, note);
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerListItem(),
        ),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () {
            if (chapterId != null) {
              ref.invalidate(notesByChapterIdProvider(chapterId!));
            } else if (bookId != null) {
              ref.invalidate(notesByBookIdProvider(bookId!));
            } else {
              ref.invalidate(userNotesProvider);
            }
          },
        ),
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    WidgetRef ref,
    NoteModel note,
  ) {
    final bookAsync = ref.watch(bookByIdProvider(note.bookId));
    final highlightColor = _parseColor(note.color ?? '#FFFF00');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/reading/${note.bookId}?chapterId=${note.chapterId}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: bookAsync.when(
                      data: (book) => Text(
                        book?.title ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      loading: () => const Text('Loading...'),
                      error: (_, _) => const Text('Unknown Book'),
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                        onTap: () {
                          final dialogContext = context;
                          Future.delayed(
                            Duration.zero,
                            () {
                              if (dialogContext.mounted) {
                                _showEditNoteDialog(dialogContext, ref, note);
                              }
                            },
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        onTap: () {
                          final dialogContext = context;
                          Future.delayed(
                            Duration.zero,
                            () {
                              if (dialogContext.mounted) {
                                _showDeleteDialog(dialogContext, ref, note);
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.menu_book, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Chapter ${note.chapterNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Highlighted text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: highlightColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: highlightColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: highlightColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        note.highlightedText,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Note text
              Text(
                note.note,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(note.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.yellow;
    }
  }

  void _showEditNoteDialog(
    BuildContext context,
    WidgetRef ref,
    NoteModel note,
  ) {
    final noteController = TextEditingController(text: note.note);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: 'Note',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(noteControllerProvider).updateNote(
                note.id,
                note: noteController.text.trim(),
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note updated')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    NoteModel note,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(noteControllerProvider).deleteNote(note.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note deleted')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportNotes(BuildContext context, WidgetRef ref, String bookId) async {
    try {
      final text = await ref.read(noteControllerProvider).exportNotesAsText(bookId);
      if (text.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No notes to export')),
          );
        }
        return;
      }
      
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting notes: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

