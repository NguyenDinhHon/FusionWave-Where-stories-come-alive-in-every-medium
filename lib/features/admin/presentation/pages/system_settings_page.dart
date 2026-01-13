import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/top_navigation_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/interactive_button.dart';

/// Trang System Settings cho admin
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Settings',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                ),
                const SizedBox(height: 32),
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
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Enable Maintenance Mode'),
                        value: _maintenanceMode,
                        onChanged: (value) {
                          setState(() {
                            _maintenanceMode = value;
                          });
                        },
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
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Allow New Registrations'),
                        subtitle: const Text(
                          'Cho phép người dùng mới đăng ký',
                        ),
                        value: _allowNewRegistrations,
                        onChanged: (value) {
                          setState(() {
                            _allowNewRegistrations = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Allow Comments'),
                        subtitle: const Text('Cho phép người dùng comment'),
                        value: _allowComments,
                        onChanged: (value) {
                          setState(() {
                            _allowComments = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Allow Ratings'),
                        subtitle: const Text('Cho phép người dùng đánh giá'),
                        value: _allowRatings,
                        onChanged: (value) {
                          setState(() {
                            _allowRatings = value;
                          });
                        },
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
                        trailing: Text('$_maxBooksPerUser'),
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
                        trailing: Text('$_maxCommentsPerUser'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Save Button
                Center(
                  child: InteractiveButton(
                    label: 'Save Settings',
                    icon: Icons.save,
                    onPressed: () {
                      _saveSettings();
                    },
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  void _saveSettings() {
    // TODO: Save settings to Firestore or local storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
