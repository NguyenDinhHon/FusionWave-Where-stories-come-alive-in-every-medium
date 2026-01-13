import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/rating_model.dart';

/// Provider for all ratings
final allRatingsProvider = FutureProvider<List<RatingModel>>((ref) async {
  final firestore = FirebaseService().firestore;
  
  try {
    Query query = firestore
        .collection(AppConstants.ratingsCollection)
        .orderBy('createdAt', descending: true)
        .limit(200);
    
    final snapshot = await query.get();
    
    List<RatingModel> ratings = snapshot.docs
        .map((doc) {
          try {
            return RatingModel.fromFirestore(doc);
          } catch (e) {
            return null;
          }
        })
        .where((rating) => rating != null)
        .cast<RatingModel>()
        .toList();
    
    ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return ratings.take(100).toList();
  } catch (e) {
    final snapshot = await firestore
        .collection(AppConstants.ratingsCollection)
        .limit(200)
        .get();
    
    List<RatingModel> ratings = snapshot.docs
        .map((doc) {
          try {
            return RatingModel.fromFirestore(doc);
          } catch (e) {
            return null;
          }
        })
        .where((rating) => rating != null)
        .cast<RatingModel>()
        .toList();
    
    ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return ratings.take(100).toList();
  }
});

/// Trang quản lý ratings
class ManageRatingsPage extends ConsumerStatefulWidget {
  const ManageRatingsPage({super.key});

  @override
  ConsumerState<ManageRatingsPage> createState() => _ManageRatingsPageState();
}

class _ManageRatingsPageState extends ConsumerState<ManageRatingsPage> {
  String _searchQuery = '';
  int? _filterRating;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveUtils.isMobile(context);
        final padding = ResponsiveUtils.pagePadding(context);
        final ratingsAsync = ref.watch(allRatingsProvider);

        return Column(
          children: [
            // Header
            Container(
              color: Theme.of(context).cardColor,
              padding: EdgeInsets.all(padding),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quản Lý Đánh Giá',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm...',
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
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: _filterRating,
                          decoration: const InputDecoration(
                            labelText: 'Lọc theo sao',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Tất cả')),
                            DropdownMenuItem(value: 5, child: Text('5 sao')),
                            DropdownMenuItem(value: 4, child: Text('4 sao')),
                            DropdownMenuItem(value: 3, child: Text('3 sao')),
                            DropdownMenuItem(value: 2, child: Text('2 sao')),
                            DropdownMenuItem(value: 1, child: Text('1 sao')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _filterRating = value;
                            });
                          },
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quản Lý Đánh Giá',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 250,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm...',
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
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 150,
                              child: DropdownButtonFormField<int>(
                                initialValue: _filterRating,
                                decoration: const InputDecoration(
                                  labelText: 'Lọc theo sao',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('Tất cả')),
                                  DropdownMenuItem(value: 5, child: Text('5 sao')),
                                  DropdownMenuItem(value: 4, child: Text('4 sao')),
                                  DropdownMenuItem(value: 3, child: Text('3 sao')),
                                  DropdownMenuItem(value: 2, child: Text('2 sao')),
                                  DropdownMenuItem(value: 1, child: Text('1 sao')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _filterRating = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            // Content
            Expanded(
              child: ratingsAsync.when(
                data: (ratings) {
                  // Filter ratings
                  var filteredRatings = ratings.where((rating) {
                    if (_searchQuery.isNotEmpty) {
                      final query = _searchQuery.toLowerCase();
                      return rating.review?.toLowerCase().contains(query) ?? false;
                    }
                    return true;
                  }).toList();

                  if (_filterRating != null) {
                    filteredRatings = filteredRatings
                        .where((rating) => rating.rating == _filterRating)
                        .toList();
                  }

                  if (filteredRatings.isEmpty) {
                    return const EmptyState(
                      title: 'Không có dữ liệu',
                      message: 'Không có đánh giá nào',
                      icon: Icons.star_border,
                    );
                  }

                  return isMobile
                      ? _buildMobileList(filteredRatings)
                      : _buildDesktopList(filteredRatings);
                },
                loading: () => const Center(
                  child: ShimmerLoading(
                    width: double.infinity,
                    height: 200,
                  ),
                ),
                error: (error, stack) => ErrorState(
                  title: 'Lỗi',
                  message: 'Lỗi khi tải đánh giá: $error',
                  onRetry: () => ref.invalidate(allRatingsProvider),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileList(List<RatingModel> ratings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ratings.length,
      itemBuilder: (context, index) {
        final rating = ratings[index];
        return _buildMobileRatingCard(rating);
      },
    );
  }

  Widget _buildDesktopList(List<RatingModel> ratings) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: ratings.length,
      itemBuilder: (context, index) {
        final rating = ratings[index];
        return _buildDesktopRatingCard(rating);
      },
    );
  }

  Widget _buildMobileRatingCard(RatingModel rating) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRatingActions(rating),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < rating.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                  const Spacer(),
                  Text(
                    _formatDate(rating.createdAt),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (rating.review != null && rating.review!.isNotEmpty)
                Text(
                  rating.review!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    'User: ${rating.userId.substring(0, 8)}...',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.book, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    'Book: ${rating.bookId.substring(0, 8)}...',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopRatingCard(RatingModel rating) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRatingActions(rating),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 24,
                  );
                }),
              ),
              const SizedBox(width: 16),
              // Review
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (rating.review != null && rating.review!.isNotEmpty)
                      Text(
                        rating.review!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      const Text(
                        'Không có review',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          'User: ${rating.userId.substring(0, 8)}...',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.book, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          'Book: ${rating.bookId.substring(0, 8)}...',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Date
              Text(
                _formatDate(rating.createdAt),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              // Actions
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () => _showRatingActions(rating),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingActions(RatingModel rating) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa đánh giá'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(rating);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Đóng'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(RatingModel rating) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteRating(rating.id);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRating(String ratingId) async {
    try {
      final firestore = FirebaseService().firestore;
      await firestore
          .collection(AppConstants.ratingsCollection)
          .doc(ratingId)
          .delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa đánh giá')),
        );
        ref.invalidate(allRatingsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
