import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/top_navigation_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Provider for all users
final allUsersProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final firestore = FirebaseService().firestore;
  final snapshot = await firestore
      .collection(AppConstants.usersCollection)
      .orderBy('createdAt', descending: true)
      .limit(100)
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    return {
      'id': doc.id,
      'email': data['email'] ?? '',
      'displayName': data['displayName'] ?? 'Unknown',
      'role': data['role'] ?? AppConstants.roleUser,
      'createdAt': data['createdAt'],
      'lastLoginAt': data['lastLoginAt'],
      'photoUrl': data['photoUrl'],
      'isBanned': data['isBanned'] ?? false,
      'bannedUntil': data['bannedUntil'],
      'banReason': data['banReason'],
    };
  }).toList();
});

/// Trang quản lý users
class ManageUsersPage extends ConsumerStatefulWidget {
  const ManageUsersPage({super.key});

  @override
  ConsumerState<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends ConsumerState<ManageUsersPage> {
  String _searchQuery = '';
  String? _roleFilter;
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return Column(
        children: [
          // Header with search, filter, view toggle
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quản Lý Users',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Row(
                  children: [
                    // Search
                    SizedBox(
                      width: 200,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Role Filter
                    DropdownButton<String>(
                      value: _roleFilter,
                      hint: const Text('Role'),
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('All Roles'),
                        ),
                        DropdownMenuItem(
                          value: AppConstants.roleUser,
                          child: Text(AppConstants.roleUser),
                        ),
                        DropdownMenuItem(
                          value: AppConstants.roleAdmin,
                          child: Text(AppConstants.roleAdmin),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _roleFilter = value;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    // View toggle
                    InteractiveButton(
                      icon: _isGridView ? Icons.view_list : Icons.grid_view,
                      onPressed: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                      tooltip: _isGridView ? 'List view' : 'Grid view',
                      isIconButton: true,
                      iconColor: AppColors.iconLight,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Users list
          Expanded(
            child: usersAsync.when(
              data: (users) {
                // Filter users
                var filteredUsers = users;
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  filteredUsers = filteredUsers.where((user) {
                    return (user['email'] as String).toLowerCase().contains(
                          query,
                        ) ||
                        (user['displayName'] as String).toLowerCase().contains(
                          query,
                        );
                  }).toList();
                }
                if (_roleFilter != null) {
                  filteredUsers = filteredUsers
                      .where((user) => user['role'] == _roleFilter)
                      .toList();
                }

                if (filteredUsers.isEmpty) {
                  return EmptyState(
                    title: 'Không tìm thấy users',
                    message: _searchQuery.isNotEmpty || _roleFilter != null
                        ? 'Thử thay đổi bộ lọc'
                        : 'Chưa có users nào',
                    icon: Icons.people_outline,
                  );
                }

                return _isGridView
                    ? _buildGridView(filteredUsers)
                    : _buildListView(filteredUsers);
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) => const ShimmerListItem(),
              ),
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
                      onPressed: () => ref.invalidate(allUsersProvider),
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

  Widget _buildListView(List<Map<String, dynamic>> users) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: user['photoUrl'] != null
                  ? NetworkImage(user['photoUrl'])
                  : null,
              child: user['photoUrl'] == null
                  ? Text(
                      (user['displayName'] as String).isNotEmpty
                          ? (user['displayName'] as String)[0].toUpperCase()
                          : 'U',
                    )
                  : null,
            ),
            title: Text(
              user['displayName'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['email'] ?? ''),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: user['role'] == AppConstants.roleAdmin
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user['role'] ?? AppConstants.roleUser,
                        style: TextStyle(
                          fontSize: 10,
                          color: user['role'] == AppConstants.roleAdmin
                              ? Colors.red
                              : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (user['isBanned'] == true) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BANNED',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user['isBanned'] == true)
                  InteractiveButton(
                    icon: Icons.check_circle,
                    onPressed: () {
                      _unbanUser(context, ref, user);
                    },
                    isIconButton: true,
                    iconColor: Colors.green,
                    tooltip: 'Unban User',
                  ),
                if (user['isBanned'] != true)
                  InteractiveButton(
                    icon: Icons.block,
                    onPressed: () {
                      _showBanDialog(context, ref, user);
                    },
                    isIconButton: true,
                    iconColor: Colors.orange,
                    tooltip: 'Ban User',
                  ),
                const SizedBox(width: 8),
                InteractiveButton(
                  icon: Icons.edit,
                  onPressed: () {
                    _showEditUserDialog(context, ref, user);
                  },
                  isIconButton: true,
                  iconColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
                InteractiveButton(
                  icon: Icons.delete,
                  onPressed: () {
                    _showDeleteConfirmation(context, ref, user);
                  },
                  isIconButton: true,
                  iconColor: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> users) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return AppCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: user['photoUrl'] != null
                    ? NetworkImage(user['photoUrl'])
                    : null,
                child: user['photoUrl'] == null
                    ? Text(
                        (user['displayName'] as String).isNotEmpty
                            ? (user['displayName'] as String)[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(fontSize: 32),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                user['displayName'] ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                user['email'] ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: user['role'] == AppConstants.roleAdmin
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  user['role'] ?? AppConstants.roleUser,
                  style: TextStyle(
                    fontSize: 10,
                    color: user['role'] == AppConstants.roleAdmin
                        ? Colors.red
                        : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditUserDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> user,
  ) {
    final roleController = TextEditingController(
      text: user['role'] ?? AppConstants.roleUser,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh Sửa User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Email: ${user['email']}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: user['role'] ?? AppConstants.roleUser,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: AppConstants.roleUser,
                  child: Text(AppConstants.roleUser),
                ),
                DropdownMenuItem(
                  value: AppConstants.roleAdmin,
                  child: Text(AppConstants.roleAdmin),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  roleController.text = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final firestore = FirebaseService().firestore;
                await firestore
                    .collection(AppConstants.usersCollection)
                    .doc(user['id'])
                    .update({'role': roleController.text});
                ref.invalidate(allUsersProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã cập nhật role thành công'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> user,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa user "${user['email']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final firestore = FirebaseService().firestore;
                await firestore
                    .collection(AppConstants.usersCollection)
                    .doc(user['id'])
                    .delete();
                ref.invalidate(allUsersProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa user thành công')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBanDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> user,
  ) {
    final reasonController = TextEditingController();
    DateTime? bannedUntil;
    bool isPermanent = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ban User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ban user: ${user['email']}'),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Permanent Ban'),
                  value: isPermanent,
                  onChanged: (value) {
                    setDialogState(() {
                      isPermanent = value ?? false;
                      if (isPermanent) {
                        bannedUntil = null;
                      }
                    });
                  },
                ),
                if (!isPermanent) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          bannedUntil = date;
                        });
                      }
                    },
                    child: Text(
                      bannedUntil == null
                          ? 'Select Ban End Date'
                          : 'Until: ${bannedUntil!.toString().split(' ')[0]}',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Ban Reason',
                    border: OutlineInputBorder(),
                    hintText: 'Enter reason for ban...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (reasonController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a ban reason'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (!isPermanent && bannedUntil == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select ban end date'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final firestore = FirebaseService().firestore;
                  await firestore
                      .collection(AppConstants.usersCollection)
                      .doc(user['id'])
                      .update({
                    'isBanned': true,
                    'bannedUntil': isPermanent
                        ? null
                        : (bannedUntil != null
                            ? Timestamp.fromDate(bannedUntil!)
                            : null),
                    'banReason': reasonController.text,
                    'bannedAt': Timestamp.now(),
                  });
                  ref.invalidate(allUsersProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User banned successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Ban', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _unbanUser(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> user,
  ) async {
    try {
      final firestore = FirebaseService().firestore;
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user['id'])
          .update({
        'isBanned': false,
        'bannedUntil': null,
        'banReason': null,
        'bannedAt': null,
      });
      ref.invalidate(allUsersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User unbanned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
