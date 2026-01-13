import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

/// Reading settings dialog with live preview
class ReadingSettingsDialog extends ConsumerStatefulWidget {
  final String previewText;
  
  const ReadingSettingsDialog({
    super.key,
    this.previewText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
  });

  @override
  ConsumerState<ReadingSettingsDialog> createState() => _ReadingSettingsDialogState();
}

class _ReadingSettingsDialogState extends ConsumerState<ReadingSettingsDialog> {
  late double _fontSize;
  late double _lineHeight;
  late String _theme;
  late double _margin;
  
  @override
  void initState() {
    super.initState();
    final prefsAsync = ref.read(preferencesServiceProvider);
    prefsAsync.whenData((prefs) {
      _fontSize = prefs.getFontSize();
      _lineHeight = prefs.getLineHeight();
      _theme = prefs.getTheme();
      _margin = 16.0; // Default margin
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(preferencesServiceProvider);
    
    return prefsAsync.when(
      data: (prefs) {
        if (_fontSize == 0) {
          _fontSize = prefs.getFontSize();
          _lineHeight = prefs.getLineHeight();
          _theme = prefs.getTheme();
        }
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reading Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Preview Section
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(_margin),
                    decoration: BoxDecoration(
                      color: _getThemeColor(_theme),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        widget.previewText,
                        style: TextStyle(
                          fontSize: _fontSize,
                          height: _lineHeight,
                          color: _getTextColor(_theme),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Font Size
                _buildSectionTitle('Font Size'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.text_decrease, size: 20),
                    Expanded(
                      child: Slider(
                        value: _fontSize,
                        min: 12,
                        max: 24,
                        divisions: 12,
                        label: _fontSize.toStringAsFixed(0),
                        onChanged: (value) {
                          setState(() => _fontSize = value);
                        },
                      ),
                    ),
                    const Icon(Icons.text_increase, size: 20),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${_fontSize.toStringAsFixed(0)}px',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Line Height
                _buildSectionTitle('Line Height'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.format_line_spacing, size: 20),
                    Expanded(
                      child: Slider(
                        value: _lineHeight,
                        min: 1.0,
                        max: 2.5,
                        divisions: 15,
                        label: _lineHeight.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() => _lineHeight = value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        _lineHeight.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Page Margins
                _buildSectionTitle('Page Margins'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.margin, size: 20),
                    Expanded(
                      child: Slider(
                        value: _margin,
                        min: 8,
                        max: 32,
                        divisions: 12,
                        label: '${_margin.toStringAsFixed(0)}px',
                        onChanged: (value) {
                          setState(() => _margin = value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${_margin.toStringAsFixed(0)}px',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Theme
                _buildSectionTitle('Theme'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: [
                    _buildThemeOption('Light', AppConstants.themeLight, Icons.light_mode),
                    _buildThemeOption('Dark', AppConstants.themeDark, Icons.dark_mode),
                    _buildThemeOption('Sepia', AppConstants.themeSepia, Icons.filter_vintage),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _saveSettings(prefs),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('Error loading settings')),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildThemeOption(String label, String value, IconData icon) {
    final isSelected = _theme == value;
    return InkWell(
      onTap: () => setState(() => _theme = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getThemeColor(String theme) {
    switch (theme) {
      case AppConstants.themeDark:
        return Colors.grey[900]!;
      case AppConstants.themeSepia:
        return const Color(0xFFF4E4BC);
      default:
        return Colors.white;
    }
  }

  Color _getTextColor(String theme) {
    switch (theme) {
      case AppConstants.themeDark:
        return Colors.white;
      case AppConstants.themeSepia:
        return const Color(0xFF5C4033);
      default:
        return Colors.black87;
    }
  }

  Future<void> _saveSettings(PreferencesService prefs) async {
    final controller = ref.read(settingsControllerProvider);
    await controller.setFontSize(_fontSize);
    await controller.setLineHeight(_lineHeight);
    await controller.setTheme(_theme);
    
    // Save margin to preferences (need to add this method)
    // await prefs.setMargin(_margin);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reading settings saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

