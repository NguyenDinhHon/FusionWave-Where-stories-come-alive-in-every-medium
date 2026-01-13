import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/export_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/user_model.dart';

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

/// Trang quản lý users - Mobile optimized
class ManageUsersPage extends ConsumerStatefulWidget {
  const ManageUsersPage({super.key});

  @override
  ConsumerState<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends ConsumerState<ManageUsersPage> {
  String _searchQuery = '';
  String? _roleFilter;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.pagePadding(context);
    final usersAsync = ref.watch(allUsersProvider);

    return Column(
      children: [
        // Header - Responsive
        Container(
          color: Theme.of(context).cardColor,
          padding: EdgeInsets.all(padding),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản Lý Users',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // White text
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm email, tên...',
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
                    DropdownButtonFormField<String>(
                      initialValue: _roleFilter,
                      decoration: InputDecoration(
                        labelText: 'Lọc theo Role',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      style: const TextStyle(color: Colors.black87),
                      dropdownColor: Colors.white,
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Tất cả', style: TextStyle(color: Colors.black87)),
                        ),
                        DropdownMenuItem(
                          value: AppConstants.roleUser,
                          child: Text(AppConstants.roleUser, style: TextStyle(color: Colors.black87)),
                        ),
                        DropdownMenuItem(
                          value: AppConstants.roleAdmin,
                          child: Text(AppConstants.roleAdmin, style: TextStyle(color: Colors.black87)),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _roleFilter = value;
                        });
                      },
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quản Lý Users',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // White text
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
                        const SizedBox(width: 12),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.file_download, color: Colors.white),
                          color: Colors.white,
                          onSelected: (value) => _exportUsers(value, usersAsync.value ?? []),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'csv', child: Text('Export CSV')),
                          ],
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _roleFilter,
                          hint: const Text('Role', style: TextStyle(color: Colors.black87)),
                          style: const TextStyle(color: Colors.black87),
                          dropdownColor: Colors.white,
                          items: const [
                            DropdownMenuItem(
                              value: null,
                              child: Text('All Roles', style: TextStyle(color: Colors.black87)),
                            ),
                            DropdownMenuItem(
                              value: AppConstants.roleUser,
                              child: Text(AppConstants.roleUser, style: TextStyle(color: Colors.black87)),
                            ),
                            DropdownMenuItem(
                              value: AppConstants.roleAdmin,
                              child: Text(AppConstants.roleAdmin, style: TextStyle(color: Colors.black87)),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _roleFilter = value;
                            });
                          },
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

              return _buildListView(filteredUsers, isMobile);
            },
            loading: () => ListView.builder(
              padding: EdgeInsets.all(padding),
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
    );
  }

  Widget _buildListView(
    List<Map<String, dynamic>> users,
    bool isMobile,
  ) {
    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveUtils.pagePadding(context)),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: isMobile
              ? _buildMobileUserCard(user)
              : _buildDesktopUserCard(user),
        );
      },
    );
  }

  Widget _buildMobileUserCard(Map<String, dynamic> user) {
    return InkWell(
      onTap: () => _showUserActionsBottomSheet(context, ref, user),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: user['photoUrl'] != null
                  ? NetworkImage(user['photoUrl'])
                  : null,
              child: user['photoUrl'] == null
                  ? Text(
                      (user['displayName'] as String).isNotEmpty
                          ? (user['displayName'] as String)[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(fontSize: 20),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['displayName'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['email'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70, // White text
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      _buildRoleBadge(user['role']),
                      if (user['isBanned'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
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
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70), // White icon
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopUserCard(Map<String, dynamic> user) {
    return ListTile(
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
              _buildRoleBadge(user['role']),
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
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () => _unbanUser(context, ref, user),
              tooltip: 'Unban User',
            ),
          if (user['isBanned'] != true)
            IconButton(
              icon: const Icon(Icons.block, color: Colors.orange),
              onPressed: () => _showBanDialog(context, ref, user),
              tooltip: 'Ban User',
            ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () => _showEditUserDialog(context, ref, user),
            tooltip: 'Edit User',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context, ref, user),
            tooltip: 'Delete User',
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String? role) {
    final isAdmin = role == AppConstants.roleAdmin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isAdmin
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role ?? AppConstants.roleUser,
        style: TextStyle(
          fontSize: 10,
          color: isAdmin ? Colors.red : Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showUserActionsBottomSheet(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> user,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user['photoUrl'] != null
                        ? NetworkImage(user['photoUrl'])
                        : null,
                    child: user['photoUrl'] == null
                        ? Text(
                            (user['displayName'] as String).isNotEmpty
                                ? (user['displayName'] as String)[0]
                                    .toUpperCase()
                                : 'U',
                            style: const TextStyle(fontSize: 24),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['displayName'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          user['email'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70, // White text
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Chỉnh sửa Role'),
              onTap: () {
                Navigator.pop(context);
                _showEditUserDialog(context, ref, user);
              },
            ),
            if (user['isBanned'] == true)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Gỡ Ban'),
                onTap: () {
                  Navigator.pop(context);
                  _unbanUser(context, ref, user);
                },
              ),
            if (user['isBanned'] != true)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.orange),
                title: const Text('Ban User'),
                onTap: () {
                  Navigator.pop(context);
                  _showBanDialog(context, ref, user);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa User'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref, user);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> user,
  ) {
    String? selectedRole = user['role'] ?? AppConstants.roleUser;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Chỉnh Sửa User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${user['email']}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.black87),
                dropdownColor: Colors.white,
                items: const [
                  DropdownMenuItem(
                    value: AppConstants.roleUser,
                    child: Text(AppConstants.roleUser, style: TextStyle(color: Colors.black87)),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.roleAdmin,
                    child: Text(AppConstants.roleAdmin, style: TextStyle(color: Colors.black87)),
                  ),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedRole = value;
                  });
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
                      .update({'role': selectedRole});
                  ref.invalidate(allUsersProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã cập nhật role thành công'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
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
                    const SnackBar(
                      content: Text('Đã xóa user thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
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
                  title: const Text('Ban Vĩnh Viễn'),
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
                          ? 'Chọn ngày hết hạn ban'
                          : 'Đến: ${bannedUntil!.toString().split(' ')[0]}',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Lý do ban',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
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
                      .update({
                    'isBanned': true,
                    'banReason': reasonController.text,
                    'bannedUntil': bannedUntil?.toIso8601String(),
                  });
                  ref.invalidate(allUsersProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã ban user thành công'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: $e'),
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

  void _unbanUser(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> user,
  ) async {
    try {
      final firestore = FirebaseService().firestore;
      await firestore.collection(AppConstants.usersCollection).doc(user['id']).update({
        'isBanned': false,
        'banReason': null,
        'bannedUntil': null,
      });
      ref.invalidate(allUsersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gỡ ban user thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportUsers(String format, List<Map<String, dynamic>> usersData) async {
    try {
      final exportService = ExportService();
      
      // Convert Map to UserModel list
      final users = usersData.map((userData) {
        return UserModel(
          id: userData['id'] ?? '',
          email: userData['email'] ?? '',
          displayName: userData['displayName'],
          photoUrl: userData['photoUrl'],
          role: userData['role'] ?? AppConstants.roleUser,
          createdAt: (userData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          lastLoginAt: (userData['lastLoginAt'] as Timestamp?)?.toDate(),
          readingStreak: 0, // Not available in userData
        );
      }).toList();

      if (format == 'csv') {
        await exportService.exportUsersToCSV(users);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã export users thành công')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi export: $e')),
        );
      }
    }
  }
}
