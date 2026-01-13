import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Library filters dialog
class LibraryFiltersDialog extends StatefulWidget {
  final String? selectedCategory;
  final double? minRating;
  final String? selectedAuthor;
  final String? dateFilter;
  final String? progressFilter;
  
  const LibraryFiltersDialog({
    super.key,
    this.selectedCategory,
    this.minRating,
    this.selectedAuthor,
    this.dateFilter,
    this.progressFilter,
  });

  @override
  State<LibraryFiltersDialog> createState() => _LibraryFiltersDialogState();
}

class _LibraryFiltersDialogState extends State<LibraryFiltersDialog> {
  String? _selectedCategory;
  double? _minRating;
  String? _selectedAuthor;
  String? _dateFilter;
  String? _progressFilter;
  
  final List<String> _categories = [
    'Fiction',
    'Non-Fiction',
    'Science',
    'History',
    'Romance',
    'Mystery',
    'Fantasy',
    'Biography',
  ];
  
  final List<String> _dateFilters = [
    'All Time',
    'This Week',
    'This Month',
    'Last 3 Months',
  ];
  
  final List<String> _progressFilters = [
    'All',
    '0-25%',
    '25-50%',
    '50-75%',
    '75-100%',
  ];
  
  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _minRating = widget.minRating;
    _selectedAuthor = widget.selectedAuthor;
    _dateFilter = widget.dateFilter ?? 'All Time';
    _progressFilter = widget.progressFilter ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
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
                    'Filters',
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
            
            // Filters content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category filter
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
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
                    
                    // Rating filter
                    Text(
                      'Minimum Rating',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _minRating ?? 0.0,
                            min: 0.0,
                            max: 5.0,
                            divisions: 10,
                            label: _minRating != null && _minRating! > 0
                                ? '${_minRating!.toStringAsFixed(1)}+'
                                : 'Any',
                            onChanged: (value) {
                              setState(() {
                                _minRating = value > 0 ? value : null;
                              });
                            },
                          ),
                        ),
                        Text(
                          _minRating != null && _minRating! > 0
                              ? '${_minRating!.toStringAsFixed(1)}+'
                              : 'Any',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Date filter
                    Text(
                      'Date Added',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _dateFilters.map((filter) {
                        final isSelected = _dateFilter == filter;
                        return ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _dateFilter = selected ? filter : 'All Time';
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Progress filter
                    Text(
                      'Reading Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _progressFilters.map((filter) {
                        final isSelected = _progressFilter == filter;
                        return ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _progressFilter = selected ? filter : 'All';
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _minRating = null;
                        _selectedAuthor = null;
                        _dateFilter = 'All Time';
                        _progressFilter = 'All';
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'category': _selectedCategory,
                            'minRating': _minRating,
                            'author': _selectedAuthor,
                            'dateFilter': _dateFilter,
                            'progressFilter': _progressFilter,
                          });
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

