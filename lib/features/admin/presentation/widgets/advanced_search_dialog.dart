import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/interactive_button.dart';

/// Dialog for advanced search with multiple filters
class AdvancedSearchDialog extends StatefulWidget {
  final String? initialSearchQuery;
  final String? initialCategory;
  final bool? initialPublishedStatus;
  final DateTime? initialDateFrom;
  final DateTime? initialDateTo;

  const AdvancedSearchDialog({
    super.key,
    this.initialSearchQuery,
    this.initialCategory,
    this.initialPublishedStatus,
    this.initialDateFrom,
    this.initialDateTo,
  });

  @override
  State<AdvancedSearchDialog> createState() => _AdvancedSearchDialogState();
}

class _AdvancedSearchDialogState extends State<AdvancedSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  bool? _publishedStatus; // null = all, true = published, false = unpublished
  DateTime? _dateFrom;
  DateTime? _dateTo;

  final List<String> _categories = [
    'All',
    'Fiction',
    'Non-Fiction',
    'Science',
    'History',
    'Romance',
    'Mystery',
    'Fantasy',
    'Biography',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialSearchQuery ?? '';
    _selectedCategory = widget.initialCategory;
    _publishedStatus = widget.initialPublishedStatus;
    _dateFrom = widget.initialDateFrom;
    _dateTo = widget.initialDateTo;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_dateFrom ?? DateTime.now()) : (_dateTo ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Tìm kiếm nâng cao',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Search Query
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm',
                hintText: 'Nhập tiêu đề, tác giả, hoặc mô tả...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Category Filter
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Thể loại',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category == 'All' ? null : category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Published Status
            Row(
              children: [
                const Text('Trạng thái: '),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: _publishedStatus == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _publishedStatus = null;
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Đã publish'),
                  selected: _publishedStatus == true,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _publishedStatus = true;
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Chưa publish'),
                  selected: _publishedStatus == false,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _publishedStatus = false;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date Range
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Từ ngày',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dateFrom != null
                            ? '${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year}'
                            : 'Chọn ngày',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Đến ngày',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dateTo != null
                            ? '${_dateTo!.day}/${_dateTo!.month}/${_dateTo!.year}'
                            : 'Chọn ngày',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InteractiveButton(
                  label: 'Xóa bộ lọc',
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _selectedCategory = null;
                      _publishedStatus = null;
                      _dateFrom = null;
                      _dateTo = null;
                    });
                  },
                  isOutlined: true,
                ),
                const SizedBox(width: 12),
                InteractiveButton(
                  label: 'Tìm kiếm',
                  icon: Icons.search,
                  onPressed: () {
                    Navigator.pop(context, {
                      'searchQuery': _searchController.text.trim(),
                      'category': _selectedCategory,
                      'publishedStatus': _publishedStatus,
                      'dateFrom': _dateFrom,
                      'dateTo': _dateTo,
                    });
                  },
                  gradient: AppColors.primaryGradient,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

