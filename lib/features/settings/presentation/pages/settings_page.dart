import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/settings_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final readingMode = ref.watch(readingModeProvider);
    final prefsAsync = ref.watch(preferencesServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: prefsAsync.when(
        data: (prefs) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Appearance Section
            _buildSectionHeader('Appearance'),
            _buildListTile(
              context,
              title: AppStrings.theme,
              subtitle: _getThemeDisplayName(theme),
              onTap: () => _showThemeDialog(context, ref),
            ),
            _buildListTile(
              context,
              title: AppStrings.fontSize,
              subtitle: '${prefs.getFontSize().toStringAsFixed(0)}px',
              onTap: () => _showFontSizeDialog(context, ref, prefs.getFontSize()),
            ),
            
            const Divider(height: 32),
            
            // Reading Section
            _buildSectionHeader('Reading'),
            _buildListTile(
              context,
              title: AppStrings.readingMode,
              subtitle: readingMode == AppConstants.readingModeScroll 
                  ? AppStrings.scrollMode 
                  : AppStrings.pageMode,
              onTap: () => _showReadingModeDialog(context, ref),
            ),
            _buildSwitchTile(
              context,
              title: AppStrings.offlineMode,
              value: prefs.getOfflineMode(),
              onChanged: (value) {
                ref.read(settingsControllerProvider).setOfflineMode(value);
              },
            ),
            
            const Divider(height: 32),
            
            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildSwitchTile(
              context,
              title: AppStrings.enableNotifications,
              value: prefs.getNotificationsEnabled(),
              onChanged: (value) {
                ref.read(settingsControllerProvider).setNotificationsEnabled(value);
              },
            ),
            _buildSwitchTile(
              context,
              title: AppStrings.dailyReminder,
              value: prefs.getDailyReminder(),
              onChanged: (value) async {
                await ref.read(settingsControllerProvider).setDailyReminder(value);
                if (value) {
                  // TODO: Schedule reminder with time picker
                } else {
                  await ref.read(notificationControllerProvider).cancelDailyReminder();
                }
              },
            ),
            
            const Divider(height: 32),
            
            // Other Section
            _buildSectionHeader('Other'),
            _buildSwitchTile(
              context,
              title: AppStrings.enableChildMode,
              value: prefs.getChildMode(),
              onChanged: (value) {
                ref.read(settingsControllerProvider).setChildMode(value);
              },
            ),
            _buildListTile(
              context,
              title: 'About',
              subtitle: 'Version 0.1.0',
              onTap: () => _showAboutDialog(context),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
  
  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case AppConstants.themeLight:
        return AppStrings.lightMode;
      case AppConstants.themeDark:
        return AppStrings.darkMode;
      case AppConstants.themeSepia:
        return AppStrings.sepiaMode;
      case AppConstants.themeAuto:
        return AppStrings.autoMode;
      default:
        return AppStrings.lightMode;
    }
  }
  
  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text(AppStrings.lightMode),
              value: AppConstants.themeLight,
              groupValue: ref.read(themeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text(AppStrings.darkMode),
              value: AppConstants.themeDark,
              groupValue: ref.read(themeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text(AppStrings.sepiaMode),
              value: AppConstants.themeSepia,
              groupValue: ref.read(themeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text(AppStrings.autoMode),
              value: AppConstants.themeAuto,
              groupValue: ref.read(themeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showReadingModeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.readingMode),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text(AppStrings.scrollMode),
              value: AppConstants.readingModeScroll,
              groupValue: ref.read(readingModeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(readingModeProvider.notifier).setReadingMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text(AppStrings.pageMode),
              value: AppConstants.readingModePage,
              groupValue: ref.read(readingModeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(readingModeProvider.notifier).setReadingMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showFontSizeDialog(BuildContext context, WidgetRef ref, double currentSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.fontSize),
        content: StatefulBuilder(
          builder: (context, setState) {
            double fontSize = currentSize;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: fontSize,
                  min: 12,
                  max: 24,
                  divisions: 12,
                  label: fontSize.toStringAsFixed(0),
                  onChanged: (value) {
                    setState(() {
                      fontSize = value;
                    });
                  },
                ),
                Text('${fontSize.toStringAsFixed(0)}px'),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Save font size
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'FusionWave Reader',
      applicationVersion: '0.1.0',
      applicationLegalese: '© 2024 FusionWave',
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}

