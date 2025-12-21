import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/top_navigation_bar.dart';

/// Categories browsing page
class CategoriesPage extends ConsumerStatefulWidget {
  final String? initialCategory;
  
  const CategoriesPage({
    super.key,
    this.initialCategory,
  });

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  String? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }
  
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Fiction', 'icon': Icons.book, 'color': Colors.blue},
    {'name': 'Non-Fiction', 'icon': Icons.article, 'color': Colors.green},
    {'name': 'Science', 'icon': Icons.science, 'color': Colors.purple},
    {'name': 'History', 'icon': Icons.history, 'color': Colors.orange},
    {'name': 'Biography', 'icon': Icons.person, 'color': Colors.red},
    {'name': 'Fantasy', 'icon': Icons.auto_stories, 'color': Colors.indigo},
    {'name': 'Mystery', 'icon': Icons.search, 'color': Colors.teal},
    {'name': 'Romance', 'icon': Icons.favorite, 'color': Colors.pink},
    {'name': 'Thriller', 'icon': Icons.movie, 'color': Colors.deepOrange},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavigationBar(),
      body: Column(
        children: [
          // Category Chips
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final isSelected = _selectedCategory == category['name'];
                  
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  category['icon'] as IconData,
                                  size: 18,
                                  color: isSelected 
                                      ? Colors.white 
                                      : category['color'] as Color,
                                ),
                                const SizedBox(width: 8),
                                Text(category['name'] as String),
                              ],
                            ),
                            selected: isSelected,
                            selectedColor: category['color'] as Color,
                            checkmarkColor: Colors.white,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected 
                                    ? category['name'] as String 
                                    : null;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Books List
          Expanded(
            child: _selectedCategory == null
                ? _buildCategoryGrid()
                : _buildBooksByCategory(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 375),
          columnCount: 2,
          child: ScaleAnimation(
            child: FadeInAnimation(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = category['name'] as String;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (category['color'] as Color).withOpacity(0.8),
                        (category['color'] as Color).withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (category['color'] as Color).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        category['name'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildBooksByCategory() {
    final booksAsync = ref.watch(booksByCategoryProvider(_selectedCategory!));
    
    return booksAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return EmptyState(
            title: 'No books in this category',
            message: 'Check back later for new content',
            icon: Icons.category_outlined,
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => context.push('/book/${books[index].id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Book cover
                            Container(
                              width: 60,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: books[index].coverImageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        books[index].coverImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.book),
                                      ),
                                    )
                                  : const Icon(Icons.book),
                            ),
                            const SizedBox(width: 12),
                            // Book info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    books[index].title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (books[index].authors.isNotEmpty)
                                    Text(
                                      books[index].authors.join(', '),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  if (books[index].averageRating != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 14, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          books[index].averageRating!.toStringAsFixed(1),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
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
        onRetry: () => ref.invalidate(booksByCategoryProvider(_selectedCategory!)),
      ),
    );
  }
}

