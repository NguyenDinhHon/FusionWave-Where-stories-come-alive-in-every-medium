import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookmark_provider.dart';

/// Dialog to add/edit bookmark
class AddBookmarkDialog extends ConsumerStatefulWidget {
  final String bookId;
  final String chapterId;
  final int chapterNumber;
  final int? pageNumber;
  final String? initialNote;
  final String? initialHighlightedText;
  
  const AddBookmarkDialog({
    super.key,
    required this.bookId,
    required this.chapterId,
    required this.chapterNumber,
    this.pageNumber,
    this.initialNote,
    this.initialHighlightedText,
  });

  @override
  ConsumerState<AddBookmarkDialog> createState() => _AddBookmarkDialogState();
}

class _AddBookmarkDialogState extends ConsumerState<AddBookmarkDialog> {
  final _noteController = TextEditingController();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _noteController.text = widget.initialNote ?? '';
  }
  
  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
  
  Future<void> _saveBookmark() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      await ref.read(bookmarkControllerProvider).addBookmark(
        bookId: widget.bookId,
        chapterId: widget.chapterId,
        chapterNumber: widget.chapterNumber,
        pageNumber: widget.pageNumber,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        highlightedText: widget.initialHighlightedText,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bookmark added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Bookmark',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Chapter ${widget.chapterNumber}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (widget.initialHighlightedText != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.initialHighlightedText!,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'Add a note to this bookmark...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveBookmark,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

