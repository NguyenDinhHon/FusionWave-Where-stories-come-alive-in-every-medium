import 'package:flutter/material.dart';

/// Dialog for bulk actions on selected items
class BulkActionsDialog extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onPublish;
  final VoidCallback? onUnpublish;
  final VoidCallback? onDelete;

  const BulkActionsDialog({
    super.key,
    required this.selectedCount,
    this.onPublish,
    this.onUnpublish,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Bulk Actions ($selectedCount selected)'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onPublish != null)
            ListTile(
              leading: const Icon(Icons.publish, color: Colors.green),
              title: const Text('Publish'),
              onTap: () {
                Navigator.pop(context);
                onPublish?.call();
              },
            ),
          if (onUnpublish != null)
            ListTile(
              leading: const Icon(Icons.unpublished, color: Colors.orange),
              title: const Text('Unpublish'),
              onTap: () {
                Navigator.pop(context);
                onUnpublish?.call();
              },
            ),
          if (onDelete != null)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

