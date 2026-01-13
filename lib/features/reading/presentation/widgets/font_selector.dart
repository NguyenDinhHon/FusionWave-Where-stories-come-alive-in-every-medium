import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reading_preferences_provider.dart';

/// Widget để chọn font family
/// Hiển thị dropdown với preview của mỗi font
class FontSelector extends ConsumerWidget {
  const FontSelector({super.key});

  static const List<String> _availableFonts = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Playfair Display',
    'Merriweather',
    'Source Sans Pro',
    'Raleway',
    'PT Serif',
    'Lora',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readingPreferencesProvider);
    final currentFont = prefs.fontFamily;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.font_download,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Phông chữ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _availableFonts.contains(currentFont)
                  ? currentFont
                  : _availableFonts.first,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              items: _availableFonts.map((font) {
                return DropdownMenuItem<String>(
                  value: font,
                  child: _FontPreviewItem(fontFamily: font),
                );
              }).toList(),
              onChanged: (newFont) {
                if (newFont != null) {
                  ref
                      .read(readingPreferencesProvider.notifier)
                      .updateFontFamily(newFont);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Preview text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'The quick brown fox jumps over the lazy dog.\nCon cáo nâu nhanh nhẹn nhảy qua con chó lười.',
            style: TextStyle(
              fontFamily: currentFont,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _FontPreviewItem extends StatelessWidget {
  final String fontFamily;

  const _FontPreviewItem({required this.fontFamily});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fontFamily,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'Abc 123',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Compact version cho dùng trong panels
class CompactFontSelector extends ConsumerWidget {
  const CompactFontSelector({super.key});

  static const List<String> _availableFonts = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Playfair Display',
    'Merriweather',
    'Source Sans Pro',
    'Raleway',
    'PT Serif',
    'Lora',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readingPreferencesProvider);
    final currentFont = prefs.fontFamily;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phông chữ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _availableFonts.contains(currentFont)
                  ? currentFont
                  : _availableFonts.first,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              items: _availableFonts.map((font) {
                return DropdownMenuItem<String>(
                  value: font,
                  child: Text(
                    font,
                    style: TextStyle(fontFamily: font),
                  ),
                );
              }).toList(),
              onChanged: (newFont) {
                if (newFont != null) {
                  ref
                      .read(readingPreferencesProvider.notifier)
                      .updateFontFamily(newFont);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
