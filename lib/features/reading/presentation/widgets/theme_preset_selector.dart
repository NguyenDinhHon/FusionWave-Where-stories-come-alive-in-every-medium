import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/reading_preferences.dart';
import '../providers/reading_preferences_provider.dart';

/// Widget để chọn theme preset
/// Hiển thị 5 theme cards: Light, Dark, Sepia, Ocean, Forest
class ThemePresetSelector extends ConsumerWidget {
  const ThemePresetSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrefs = ref.watch(readingPreferencesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                Icons.palette,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Chủ đề có sẵn',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _ThemePresetCard(
                name: 'Sáng',
                icon: Icons.wb_sunny,
                preset: ReadingPreferences.lightPreset,
                isSelected: _isPresetSelected(
                  currentPrefs,
                  ReadingPreferences.lightPreset,
                ),
                onTap: () {
                  ref
                      .read(readingPreferencesProvider.notifier)
                      .applyPreset(ReadingPreferences.lightPreset);
                },
              ),
              const SizedBox(width: 12),
              _ThemePresetCard(
                name: 'Tối',
                icon: Icons.nightlight_round,
                preset: ReadingPreferences.darkPreset,
                isSelected: _isPresetSelected(
                  currentPrefs,
                  ReadingPreferences.darkPreset,
                ),
                onTap: () {
                  ref
                      .read(readingPreferencesProvider.notifier)
                      .applyPreset(ReadingPreferences.darkPreset);
                },
              ),
              const SizedBox(width: 12),
              _ThemePresetCard(
                name: 'Sepia',
                icon: Icons.auto_stories,
                preset: ReadingPreferences.sepiaPreset,
                isSelected: _isPresetSelected(
                  currentPrefs,
                  ReadingPreferences.sepiaPreset,
                ),
                onTap: () {
                  ref
                      .read(readingPreferencesProvider.notifier)
                      .applyPreset(ReadingPreferences.sepiaPreset);
                },
              ),
              const SizedBox(width: 12),
              _ThemePresetCard(
                name: 'Đại dương',
                icon: Icons.water,
                preset: ReadingPreferences.oceanPreset,
                isSelected: _isPresetSelected(
                  currentPrefs,
                  ReadingPreferences.oceanPreset,
                ),
                onTap: () {
                  ref
                      .read(readingPreferencesProvider.notifier)
                      .applyPreset(ReadingPreferences.oceanPreset);
                },
              ),
              const SizedBox(width: 12),
              _ThemePresetCard(
                name: 'Rừng',
                icon: Icons.forest,
                preset: ReadingPreferences.forestPreset,
                isSelected: _isPresetSelected(
                  currentPrefs,
                  ReadingPreferences.forestPreset,
                ),
                onTap: () {
                  ref
                      .read(readingPreferencesProvider.notifier)
                      .applyPreset(ReadingPreferences.forestPreset);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isPresetSelected(
    ReadingPreferences current,
    ReadingPreferences preset,
  ) {
    return current.backgroundColor == preset.backgroundColor &&
        current.textColor == preset.textColor;
  }
}

class _ThemePresetCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final ReadingPreferences preset;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemePresetCard({
    required this.name,
    required this.icon,
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 140,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Background with preset colors
              Container(
                decoration: BoxDecoration(
                  color: preset.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon with preset colors
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: preset.textColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: preset.textColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Name
                    Text(
                      name,
                      style: TextStyle(
                        color: preset.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Selected indicator
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
