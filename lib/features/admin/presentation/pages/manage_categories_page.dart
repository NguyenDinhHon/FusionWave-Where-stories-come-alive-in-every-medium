import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
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

/// Trang quản lý categories - Mobile optimized
class ManageCategoriesPage extends ConsumerStatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  ConsumerState<ManageCategoriesPage> createState() =>
      _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends ConsumerState<ManageCategoriesPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.pagePadding(context);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      children: [
        // Header - Responsive
        Container(
          color: Theme.of(context).cardColor,
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quản Lý Categories',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White text
                        ),
                  ),
                  if (!isMobile)
                    InteractiveButton(
                      label: 'Thêm Category',
                      icon: Icons.add,
                      onPressed: () => _showAddCategoryInfo(context),
                      gradient: AppColors.primaryGradient,
                    ),
                ],
              ),
              if (isMobile) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: InteractiveButton(
                    label: 'Thêm Category',
                    icon: Icons.add,
                    onPressed: () => _showAddCategoryInfo(context),
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm category...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
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

              final gridCount = isMobile
                  ? 2
                  : ResponsiveUtils.gridCountForWidth(
                      MediaQuery.of(context).size.width,
                      minItemWidth: 200,
                      maxCount: 4,
                    );

              return GridView.builder(
                padding: EdgeInsets.all(padding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isMobile ? 2.0 : 2.5,
                ),
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return AppCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 14 : 16,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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
    );
  }

  void _showAddCategoryInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin Categories'),
        content: const Text(
          'Categories được quản lý thông qua sách. '
          'Khi bạn tạo hoặc chỉnh sửa sách, bạn có thể thêm categories cho sách đó. '
          'Danh sách categories ở đây là tất cả các categories đã được sử dụng trong các sách.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }
}
