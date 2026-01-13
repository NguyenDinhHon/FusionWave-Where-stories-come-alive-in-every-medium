import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/top_navigation_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Provider for categories
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final firestore = FirebaseService().firestore;
  final snapshot = await firestore
      .collection(AppConstants.booksCollection)
      .get();

  final categories = <String>{};
  for (var doc in snapshot.docs) {
    final data = doc.data();
    final bookCategories = data['categories'] as List<dynamic>? ?? [];
    for (var cat in bookCategories) {
      if (cat is String) {
        categories.add(cat);
      }
    }
  }
  return categories.toList()..sort();
});

/// Trang quản lý categories
class ManageCategoriesPage extends ConsumerStatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  ConsumerState<ManageCategoriesPage> createState() =>
      _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends ConsumerState<ManageCategoriesPage> {
  final _categoryController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: const TopNavigationBar(),
      body: Column(
        children: [
          // Header
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quản Lý Categories',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                    ),
                    InteractiveButton(
                      label: 'Thêm Category',
                      icon: Icons.add,
                      onPressed: () => _showAddCategoryDialog(context),
                      gradient: AppColors.primaryGradient,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm category...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),
          // Categories list
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                var filteredCategories = categories;
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  filteredCategories = filteredCategories
                      .where((cat) => cat.toLowerCase().contains(query))
                      .toList();
                }

                if (filteredCategories.isEmpty) {
                  return EmptyState(
                    title: 'Không tìm thấy categories',
                    message: _searchQuery.isNotEmpty
                        ? 'Thử thay đổi từ khóa tìm kiếm'
                        : 'Chưa có categories nào',
                    icon: Icons.category_outlined,
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return AppCard(
                      child: Center(
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    InteractiveButton(
                      label: 'Retry',
                      icon: Icons.refresh,
                      onPressed: () => ref.invalidate(categoriesProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    _categoryController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Category'),
        content: TextField(
          controller: _categoryController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_categoryController.text.isNotEmpty) {
                // Note: Categories are stored in books, so this is just for reference
                // In a real app, you might want a separate categories collection
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Category sẽ được thêm khi tạo/sửa sách',
                    ),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
