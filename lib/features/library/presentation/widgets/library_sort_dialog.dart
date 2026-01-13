import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Library sort dialog
class LibrarySortDialog extends StatelessWidget {
  final String currentSort;
  
  const LibrarySortDialog({
    super.key,
    required this.currentSort,
  });

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      {'value': 'title_asc', 'label': 'Title (A-Z)', 'icon': Icons.sort_by_alpha},
      {'value': 'title_desc', 'label': 'Title (Z-A)', 'icon': Icons.sort_by_alpha},
      {'value': 'author_asc', 'label': 'Author (A-Z)', 'icon': Icons.person},
      {'value': 'author_desc', 'label': 'Author (Z-A)', 'icon': Icons.person},
      {'value': 'date_added_desc', 'label': 'Date Added (Newest)', 'icon': Icons.calendar_today},
      {'value': 'date_added_asc', 'label': 'Date Added (Oldest)', 'icon': Icons.calendar_today},
      {'value': 'progress_desc', 'label': 'Progress (Most)', 'icon': Icons.trending_up},
      {'value': 'progress_asc', 'label': 'Progress (Least)', 'icon': Icons.trending_down},
      {'value': 'rating_desc', 'label': 'Rating (Highest)', 'icon': Icons.star},
      {'value': 'rating_asc', 'label': 'Rating (Lowest)', 'icon': Icons.star_border},
    ];
    
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sort By',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Sort options
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sortOptions.length,
                itemBuilder: (context, index) {
                  final option = sortOptions[index];
                  final isSelected = currentSort == option['value'];
                  
                  return RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(
                          option['icon'] as IconData,
                          size: 20,
                          color: isSelected ? AppColors.primary : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(option['label'] as String),
                      ],
                    ),
                    value: option['value'] as String,
                    // ignore: deprecated_member_use
                    groupValue: currentSort,
                    // ignore: deprecated_member_use
                    onChanged: (value) {
                      Navigator.pop(context, value);
                    },
                    activeColor: AppColors.primary,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

