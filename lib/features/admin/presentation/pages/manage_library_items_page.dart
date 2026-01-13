import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/library_item_model.dart';

/// Provider for all library items
final allLibraryItemsProvider = FutureProvider<List<LibraryItemModel>>((ref) async {
  final firestore = FirebaseService().firestore;
  
  try {
    Query query = firestore
        .collection(AppConstants.libraryCollection)
        .orderBy('addedAt', descending: true)
        .limit(200);
    
    final snapshot = await query.get();
    
    List<LibraryItemModel> items = snapshot.docs
        .map((doc) {
          try {
            return LibraryItemModel.fromFirestore(doc);
          } catch (e) {
            return null;
          }
        })
        .where((item) => item != null)
        .cast<LibraryItemModel>()
        .toList();
    
    items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    
    return items.take(100).toList();
  } catch (e) {
    final snapshot = await firestore
        .collection(AppConstants.libraryCollection)
        .limit(200)
        .get();
    
    List<LibraryItemModel> items = snapshot.docs
        .map((doc) {
          try {
            return LibraryItemModel.fromFirestore(doc);
          } catch (e) {
            return null;
          }
        })
        .where((item) => item != null)
        .cast<LibraryItemModel>()
        .toList();
    
    items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    
    return items.take(100).toList();
  }
});

/// Trang quản lý library items
class ManageLibraryItemsPage extends ConsumerStatefulWidget {
  const ManageLibraryItemsPage({super.key});

  @override
  ConsumerState<ManageLibraryItemsPage> createState() => _ManageLibraryItemsPageState();
}

class _ManageLibraryItemsPageState extends ConsumerState<ManageLibraryItemsPage> {
  String? _filterStatus;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveUtils.isMobile(context);
        final padding = ResponsiveUtils.pagePadding(context);
        final itemsAsync = ref.watch(allLibraryItemsProvider);

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
                          'Quản Lý Thư Viện',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _filterStatus,
                          decoration: const InputDecoration(
                            labelText: 'Lọc theo trạng thái',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: const TextStyle(color: Colors.black87),
                          dropdownColor: Colors.white,
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Tất cả', style: TextStyle(color: Colors.black87))),
                            DropdownMenuItem(value: AppConstants.bookStatusReading, child: Text('Đang đọc', style: TextStyle(color: Colors.black87))),
                            DropdownMenuItem(value: AppConstants.bookStatusCompleted, child: Text('Đã hoàn thành', style: TextStyle(color: Colors.black87))),
                            DropdownMenuItem(value: AppConstants.bookStatusWantToRead, child: Text('Muốn đọc', style: TextStyle(color: Colors.black87))),
                            DropdownMenuItem(value: AppConstants.bookStatusDropped, child: Text('Đã bỏ', style: TextStyle(color: Colors.black87))),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _filterStatus = value;
                            });
                          },
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quản Lý Thư Viện',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        SizedBox(
                          width: 180,
                          child: DropdownButtonFormField<String>(
                            initialValue: _filterStatus,
                            decoration: const InputDecoration(
                              labelText: 'Lọc theo trạng thái',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: const TextStyle(color: Colors.black87),
                            dropdownColor: Colors.white,
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Tất cả', style: TextStyle(color: Colors.black87))),
                              DropdownMenuItem(value: AppConstants.bookStatusReading, child: Text('Đang đọc', style: TextStyle(color: Colors.black87))),
                              DropdownMenuItem(value: AppConstants.bookStatusCompleted, child: Text('Đã hoàn thành', style: TextStyle(color: Colors.black87))),
                              DropdownMenuItem(value: AppConstants.bookStatusWantToRead, child: Text('Muốn đọc', style: TextStyle(color: Colors.black87))),
                              DropdownMenuItem(value: AppConstants.bookStatusDropped, child: Text('Đã bỏ', style: TextStyle(color: Colors.black87))),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _filterStatus = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
            ),
            // Content
            Expanded(
              child: itemsAsync.when(
                data: (items) {
                  // Filter items (search query not used yet, can be added later)
                  var filteredItems = items.where((item) {
                    if (_filterStatus != null && item.status != _filterStatus) {
                      return false;
                    }
                    return true;
                  }).toList();

                  if (filteredItems.isEmpty) {
                    return const EmptyState(
                      title: 'Không có dữ liệu',
                      message: 'Không có library item nào',
                      icon: Icons.library_books,
                    );
                  }

                  return isMobile
                      ? _buildMobileList(filteredItems)
                      : _buildDesktopList(filteredItems);
                },
                loading: () => const Center(
                  child: ShimmerLoading(
                    width: double.infinity,
                    height: 200,
                  ),
                ),
                error: (error, stack) => ErrorState(
                  title: 'Lỗi',
                  message: 'Lỗi khi tải library items: $error',
                  onRetry: () => ref.invalidate(allLibraryItemsProvider),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileList(List<LibraryItemModel> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildMobileItemCard(item);
      },
    );
  }

  Widget _buildDesktopList(List<LibraryItemModel> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildDesktopItemCard(item);
      },
    );
  }

  Widget _buildMobileItemCard(LibraryItemModel item) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusChip(item.status),
                const Spacer(),
                Text(
                  '${(item.progress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: item.progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  'User: ${item.userId.substring(0, 8)}...',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.book, size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  'Book: ${item.bookId.substring(0, 8)}...',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.menu_book, size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  'Chapter ${item.currentChapter}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.timer, size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  '${item.totalReadingTimeMinutes} phút',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (item.lastReadAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Đọc lần cuối: ${_formatDate(item.lastReadAt!)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopItemCard(LibraryItemModel item) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStatusChip(item.status),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        'User: ${item.userId.substring(0, 8)}...',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.book, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        'Book: ${item.bookId.substring(0, 8)}...',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.menu_book, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        'Chapter ${item.currentChapter}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.timer, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        '${item.totalReadingTimeMinutes} phút',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: item.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${(item.progress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            if (item.lastReadAt != null)
              Text(
                _formatDate(item.lastReadAt!),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case AppConstants.bookStatusReading:
        color = Colors.blue;
        label = 'Đang đọc';
        break;
      case AppConstants.bookStatusCompleted:
        color = Colors.green;
        label = 'Đã hoàn thành';
        break;
      case AppConstants.bookStatusWantToRead:
        color = Colors.orange;
        label = 'Muốn đọc';
        break;
      case AppConstants.bookStatusDropped:
        color = Colors.red;
        label = 'Đã bỏ';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
