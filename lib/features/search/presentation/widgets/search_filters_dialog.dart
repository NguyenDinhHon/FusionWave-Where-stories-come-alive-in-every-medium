import 'package:flutter/material.dart';

/// Search filters dialog
class SearchFiltersDialog extends StatefulWidget {
  final String? initialCategory;
  final double? minRating;
  final String? author;
  
  const SearchFiltersDialog({
    super.key,
    this.initialCategory,
    this.minRating,
    this.author,
  });

  @override
  State<SearchFiltersDialog> createState() => _SearchFiltersDialogState();
}

class _SearchFiltersDialogState extends State<SearchFiltersDialog> {
  String? _selectedCategory;
  double? _minRating;
  final _authorController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _minRating = widget.minRating;
    _authorController.text = widget.author ?? '';
  }
  
  @override
  void dispose() {
    _authorController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final categories = [
      'Fiction',
      'Non-Fiction',
      'Science',
      'History',
      'Biography',
      'Fantasy',
      'Mystery',
      'Romance',
      'Thriller',
    ];
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Search Filters',
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
            const SizedBox(height: 24),
            
            // Category Filter
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            
            // Rating Filter
            const Text(
              'Minimum Rating',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _minRating ?? 0.0,
                    min: 0.0,
                    max: 5.0,
                    divisions: 10,
                    label: _minRating != null ? _minRating!.toStringAsFixed(1) : 'Any',
                    onChanged: (value) {
                      setState(() => _minRating = value);
                    },
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    _minRating != null && _minRating! > 0
                        ? _minRating!.toStringAsFixed(1)
                        : 'Any',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Author Filter
            const Text(
              'Author',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(
                hintText: 'Filter by author name...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                      _minRating = null;
                      _authorController.clear();
                    });
                  },
                  child: const Text('Clear All'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'category': _selectedCategory,
                      'minRating': _minRating != null && _minRating! > 0 ? _minRating : null,
                      'author': _authorController.text.trim().isEmpty 
                          ? null 
                          : _authorController.text.trim(),
                    });
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

