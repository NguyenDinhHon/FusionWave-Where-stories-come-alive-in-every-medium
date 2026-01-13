import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../core/services/firebase_service.dart';

/// Provider for system settings
final systemSettingsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final firestore = FirebaseService().firestore;
  final doc = await firestore
      .collection('system')
      .doc('settings')
      .get();
  
  if (doc.exists) {
    return doc.data()!;
  }
  
  // Default settings
  return {
    'maintenanceMode': false,
    'allowNewRegistrations': true,
    'allowComments': true,
    'allowRatings': true,
    'maxBooksPerUser': 100,
    'maxCommentsPerUser': 50,
  };
});

/// Trang System Settings cho admin - Mobile optimized
class SystemSettingsPage extends ConsumerStatefulWidget {
  const SystemSettingsPage({super.key});

  @override
  ConsumerState<SystemSettingsPage> createState() =>
      _SystemSettingsPageState();
}

class _SystemSettingsPageState extends ConsumerState<SystemSettingsPage> {
  bool _maintenanceMode = false;
  bool _allowNewRegistrations = true;
  bool _allowComments = true;
  bool _allowRatings = true;
  int _maxBooksPerUser = 100;
  int _maxCommentsPerUser = 50;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // Settings will be loaded in build method via watch
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.pagePadding(context);
    final settingsAsync = ref.watch(systemSettingsProvider);

    return settingsAsync.when(
      data: (settings) {
        if (!_isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _maintenanceMode = settings['maintenanceMode'] ?? false;
              _allowNewRegistrations = settings['allowNewRegistrations'] ?? true;
              _allowComments = settings['allowComments'] ?? true;
              _allowRatings = settings['allowRatings'] ?? true;
              _maxBooksPerUser = settings['maxBooksPerUser'] ?? 100;
              _maxCommentsPerUser = settings['maxCommentsPerUser'] ?? 50;
              _isInitialized = true;
            });
          });
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 800,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  'System Settings',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text
                      ),
                ),
                  const SizedBox(height: 24),
                  // Maintenance Mode
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maintenance Mode',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Khi bật, chỉ admin mới có thể truy cập hệ thống',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text('Bật Maintenance Mode'),
                          value: _maintenanceMode,
                          onChanged: (value) {
                            setState(() {
                              _maintenanceMode = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Access Control
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Access Control',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text('Cho phép đăng ký mới'),
                          subtitle: const Text(
                            'Cho phép người dùng mới đăng ký',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _allowNewRegistrations,
                          onChanged: (value) {
                            setState(() {
                              _allowNewRegistrations = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        SwitchListTile(
                          title: const Text('Cho phép Comments'),
                          subtitle: const Text(
                            'Cho phép người dùng comment',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _allowComments,
                          onChanged: (value) {
                            setState(() {
                              _allowComments = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        SwitchListTile(
                          title: const Text('Cho phép Ratings'),
                          subtitle: const Text(
                            'Cho phép người dùng đánh giá',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _allowRatings,
                          onChanged: (value) {
                            setState(() {
                              _allowRatings = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Limits
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Limits',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Max Books Per User'),
                          subtitle: Slider(
                            value: _maxBooksPerUser.toDouble(),
                            min: 10,
                            max: 500,
                            divisions: 49,
                            label: _maxBooksPerUser.toString(),
                            onChanged: (value) {
                              setState(() {
                                _maxBooksPerUser = value.toInt();
                              });
                            },
                          ),
                          trailing: Text(
                            '$_maxBooksPerUser',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          title: const Text('Max Comments Per User'),
                          subtitle: Slider(
                            value: _maxCommentsPerUser.toDouble(),
                            min: 10,
                            max: 200,
                            divisions: 19,
                            label: _maxCommentsPerUser.toString(),
                            onChanged: (value) {
                              setState(() {
                                _maxCommentsPerUser = value.toInt();
                              });
                            },
                          ),
                          trailing: Text(
                            '$_maxCommentsPerUser',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: InteractiveButton(
                      label: _isLoading ? 'Đang lưu...' : 'Lưu Settings',
                      icon: _isLoading ? null : Icons.save,
                      onPressed: _isLoading ? null : _saveSettings,
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            InteractiveButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: () => ref.invalidate(systemSettingsProvider),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final firestore = FirebaseService().firestore;
      await firestore.collection('system').doc('settings').set({
        'maintenanceMode': _maintenanceMode,
        'allowNewRegistrations': _allowNewRegistrations,
        'allowComments': _allowComments,
        'allowRatings': _allowRatings,
        'maxBooksPerUser': _maxBooksPerUser,
        'maxCommentsPerUser': _maxCommentsPerUser,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      ref.invalidate(systemSettingsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu settings thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
