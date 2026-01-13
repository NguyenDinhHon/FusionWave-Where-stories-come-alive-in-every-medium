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
import '../../../../data/models/collection_model.dart';

/// Provider for all collections
final allCollectionsProvider = FutureProvider<List<CollectionModel>>((ref) async {
  final firestore = FirebaseService().firestore;
  
  try {
    Query query = firestore
        .collection(AppConstants.collectionsCollection)
        .orderBy('updatedAt', descending: true)
        .limit(200);
    
    final snapshot = await query.get();
    
    List<CollectionModel> collections = snapshot.docs
        .map((doc) {
          try {
            return CollectionModel.fromFirestore(doc);
          } catch (e) {
            return null;
          }
        })
        .where((collection) => collection != null)
        .cast<CollectionModel>()
        .toList();
    
    collections.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    return collections.take(100).toList();
  } catch (e) {
    final snapshot = await firestore
        .collection(AppConstants.collectionsCollection)
        .limit(200)
        .get();
    
    List<CollectionModel> collections = snapshot.docs
        .map((doc) {
          try {
            return CollectionModel.fromFirestore(doc);
          } catch (e) {
            return null;
          }
        })
        .where((collection) => collection != null)
        .cast<CollectionModel>()
        .toList();
    
    collections.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    return collections.take(100).toList();
  }
});

/// Trang quản lý collections
class ManageCollectionsPage extends ConsumerStatefulWidget {
  const ManageCollectionsPage({super.key});

  @override
  ConsumerState<ManageCollectionsPage> createState() => _ManageCollectionsPageState();
}

class _ManageCollectionsPageState extends ConsumerState<ManageCollectionsPage> {
  String _searchQuery = '';
  bool _filterPublicOnly = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveUtils.isMobile(context);
        final padding = ResponsiveUtils.pagePadding(context);
        final collectionsAsync = ref.watch(allCollectionsProvider);

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
                          'Quản Lý Collections',
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
                        CheckboxListTile(
                          title: const Text('Chỉ hiển thị public'),
                          value: _filterPublicOnly,
                          onChanged: (value) {
                            setState(() {
                              _filterPublicOnly = value ?? false;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quản Lý Collections',
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
                            CheckboxListTile(
                              title: const Text('Chỉ public'),
                              value: _filterPublicOnly,
                              onChanged: (value) {
                                setState(() {
                                  _filterPublicOnly = value ?? false;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            // Content
            Expanded(
              child: collectionsAsync.when(
                data: (collections) {
                  // Filter collections
                  var filteredCollections = collections.where((collection) {
                    if (_searchQuery.isNotEmpty) {
                      final query = _searchQuery.toLowerCase();
                      final nameMatch = collection.name.toLowerCase().contains(query);
                      final descMatch = collection.description?.toLowerCase().contains(query) ?? false;
                      if (!nameMatch && !descMatch) return false;
                    }
                    if (_filterPublicOnly && !collection.isPublic) {
                      return false;
                    }
                    return true;
                  }).toList();

                  if (filteredCollections.isEmpty) {
                    return const EmptyState(
                      title: 'Không có dữ liệu',
                      message: 'Không có collection nào',
                      icon: Icons.collections,
                    );
                  }

                  return isMobile
                      ? _buildMobileGrid(filteredCollections)
                      : _buildDesktopGrid(filteredCollections);
                },
                loading: () => const Center(
                  child: ShimmerLoading(
                    width: double.infinity,
                    height: 200,
                  ),
                ),
                error: (error, stack) => ErrorState(
                  title: 'Lỗi',
                  message: 'Lỗi khi tải collections: $error',
                  onRetry: () => ref.invalidate(allCollectionsProvider),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileGrid(List<CollectionModel> collections) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return _buildMobileCollectionCard(collection);
      },
    );
  }

  Widget _buildDesktopGrid(List<CollectionModel> collections) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return _buildDesktopCollectionCard(collection);
      },
    );
  }

  Widget _buildMobileCollectionCard(CollectionModel collection) {
    return AppCard(
      child: InkWell(
        onTap: () => _showCollectionActions(collection),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: collection.coverImageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          collection.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.collections, size: 40), // ignore: unnecessary_underscores
                        ),
                      )
                    : const Icon(Icons.collections, size: 40),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        collection.isPublic ? Icons.public : Icons.lock,
                        size: 12,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${collection.bookIds.length} sách',
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
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopCollectionCard(CollectionModel collection) {
    return AppCard(
      child: InkWell(
        onTap: () => _showCollectionActions(collection),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: collection.coverImageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          collection.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.collections, size: 60), // ignore: unnecessary_underscores
                        ),
                      )
                    : const Icon(Icons.collections, size: 60),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (collection.description != null && collection.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                  Text(
                    collection.description!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            collection.isPublic ? Icons.public : Icons.lock,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${collection.bookIds.length} sách',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 18, color: Colors.white),
                        onPressed: () => _showCollectionActions(collection),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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

  void _showCollectionActions(CollectionModel collection) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text('Tên: ${collection.name}'),
              subtitle: Text('${collection.bookIds.length} sách'),
            ),
            ListTile(
              leading: Icon(
                collection.isPublic ? Icons.public : Icons.lock,
              ),
              title: Text(collection.isPublic ? 'Public' : 'Private'),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa collection'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(collection);
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

  void _showDeleteConfirmation(CollectionModel collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa collection "${collection.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCollection(collection.id);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCollection(String collectionId) async {
    try {
      final firestore = FirebaseService().firestore;
      await firestore
          .collection(AppConstants.collectionsCollection)
          .doc(collectionId)
          .delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa collection')),
        );
        ref.invalidate(allCollectionsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }
}
