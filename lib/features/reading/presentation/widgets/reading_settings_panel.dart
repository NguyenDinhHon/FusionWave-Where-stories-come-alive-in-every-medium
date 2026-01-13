import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reading_preferences_provider.dart';
import '../../domain/models/reading_preferences.dart';

/// Panel settings slide từ bên phải
/// Chứa các controls cho typography, theme, layout
class ReadingSettingsPanel extends ConsumerStatefulWidget {
  const ReadingSettingsPanel({super.key});

  @override
  ConsumerState<ReadingSettingsPanel> createState() =>
      _ReadingSettingsPanelState();
}

class _ReadingSettingsPanelState extends ConsumerState<ReadingSettingsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closePanel() {
    _controller.reverse().then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(readingPreferencesProvider);

    return GestureDetector(
      onTap: _closePanel,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: GestureDetector(
          onTap: () {}, // Prevent closing when tapping panel
          child: SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(-4, 0),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header
                      _buildHeader(context),

                      const Divider(height: 1),

                      // Settings content
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            _buildTypographySection(context, prefs),
                            const SizedBox(height: 24),
                            _buildThemeSection(context),
                            const SizedBox(height: 24),
                            _buildLayoutSection(context, prefs),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _closePanel,
            tooltip: 'Đóng',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cài đặt đọc',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              ref
                  .read(readingPreferencesProvider.notifier)
                  .resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã khôi phục cài đặt mặc định'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypographySection(
    BuildContext context,
    ReadingPreferences prefs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, Icons.text_fields, 'Kiểu chữ'),
        const SizedBox(height: 16),

        // Font size
        _buildSlider(
          context: context,
          label: 'Cỡ chữ',
          value: prefs.fontSize,
          min: 12,
          max: 32,
          divisions: 20,
          displayValue: '${prefs.fontSize.toInt()}px',
          onChanged: (value) {
            ref
                .read(readingPreferencesProvider.notifier)
                .updateFontSize(value);
          },
        ),

        const SizedBox(height: 16),

        // Line height
        _buildSlider(
          context: context,
          label: 'Khoảng cách dòng',
          value: prefs.lineHeight,
          min: 1.0,
          max: 2.5,
          divisions: 15,
          displayValue: prefs.lineHeight.toStringAsFixed(1),
          onChanged: (value) {
            ref
                .read(readingPreferencesProvider.notifier)
                .updateLineHeight(value);
          },
        ),

        const SizedBox(height: 16),

        // Letter spacing
        _buildSlider(
          context: context,
          label: 'Khoảng cách chữ',
          value: prefs.letterSpacing,
          min: 0,
          max: 2,
          divisions: 20,
          displayValue: prefs.letterSpacing.toStringAsFixed(1),
          onChanged: (value) {
            ref
                .read(readingPreferencesProvider.notifier)
                .updateLetterSpacing(value);
          },
        ),
      ],
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, Icons.palette, 'Giao diện'),
        const SizedBox(height: 12),
        const Text(
          'Xem phần "Theme Presets" bên dưới để chọn theme có sẵn',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildLayoutSection(
    BuildContext context,
    ReadingPreferences prefs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, Icons.format_align_left, 'Bố cục'),
        const SizedBox(height: 16),

        // Horizontal margins
        _buildSlider(
          context: context,
          label: 'Lề ngang',
          value: prefs.margins.horizontal,
          min: 0,
          max: 48,
          divisions: 24,
          displayValue: '${prefs.margins.horizontal.toInt()}px',
          onChanged: (value) {
            ref
                .read(readingPreferencesProvider.notifier)
                .updateMarginHorizontal(value);
          },
        ),

        const SizedBox(height: 16),

        // Vertical margins
        _buildSlider(
          context: context,
          label: 'Lề dọc',
          value: prefs.margins.vertical,
          min: 0,
          max: 48,
          divisions: 24,
          displayValue: '${prefs.margins.vertical.toInt()}px',
          onChanged: (value) {
            ref
                .read(readingPreferencesProvider.notifier)
                .updateMarginVertical(value);
          },
        ),

        const SizedBox(height: 16),

        // Text alignment
        _buildTextAlignmentSelector(context, prefs),
      ],
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required BuildContext context,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                displayValue,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextAlignmentSelector(
    BuildContext context,
    ReadingPreferences prefs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Canh lề',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildAlignmentButton(
              context,
              TextAlign.left,
              Icons.format_align_left,
              prefs.textAlign == TextAlign.left,
            ),
            const SizedBox(width: 8),
            _buildAlignmentButton(
              context,
              TextAlign.center,
              Icons.format_align_center,
              prefs.textAlign == TextAlign.center,
            ),
            const SizedBox(width: 8),
            _buildAlignmentButton(
              context,
              TextAlign.right,
              Icons.format_align_right,
              prefs.textAlign == TextAlign.right,
            ),
            const SizedBox(width: 8),
            _buildAlignmentButton(
              context,
              TextAlign.justify,
              Icons.format_align_justify,
              prefs.textAlign == TextAlign.justify,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlignmentButton(
    BuildContext context,
    TextAlign alignment,
    IconData icon,
    bool isSelected,
  ) {
    return Expanded(
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            ref
                .read(readingPreferencesProvider.notifier)
                .updateTextAlign(alignment);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function để show settings panel
void showReadingSettingsPanel(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ReadingSettingsPanel(),
    ),
  );
}
