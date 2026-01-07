import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/reading_mode.dart';
import '../../domain/models/reading_preferences.dart';
import '../../domain/models/chapter.dart';
import '../providers/reading_mode_provider.dart';
import '../providers/reading_preferences_provider.dart';
import '../providers/current_chapter_provider.dart';
class ReadingPhase1TestPage extends ConsumerWidget {
  const ReadingPhase1TestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingMode = ref.watch(readingModeProvider);
    final preferences = ref.watch(readingPreferencesProvider);
    final currentChapterIndex = ref.watch(chapterNavigationProvider);
    final controlsVisible = ref.watch(controlsVisibilityProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 1 Test - Models & Providers'),
        backgroundColor: preferences.accentColor,
      ),
      backgroundColor: preferences.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reading Mode Test
            _buildSection(
              context,
              'Reading Mode',
              Column(
                children: [
                  Text(
                    'Current: ${readingMode.displayName}',
                    style: TextStyle(
                      color: preferences.textColor,
                      fontSize: preferences.fontSize,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ReadingMode.values.map((mode) {
                      return ChoiceChip(
                        label: Text(mode.displayName),
                        selected: readingMode == mode,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(readingModeProvider.notifier).setMode(mode);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 32),
            
            // Controls Visibility Test
            _buildSection(
              context,
              'Controls',
              Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Controls Visible',
                      style: TextStyle(color: preferences.textColor),
                    ),
                    value: controlsVisible,
                    onChanged: (value) {
                      if (value) {
                        ref.read(controlsVisibilityProvider.notifier).show();
                      } else {
                        ref.read(controlsVisibilityProvider.notifier).hide();
                      }
                    },
                  ),
                ],
              ),
            ),
            
            const Divider(height: 32),
            
            // Theme Presets Test
            _buildSection(
              context,
              'Theme Presets',
              Column(
                children: [
                  Text(
                    'Tap to apply presets:',
                    style: TextStyle(color: preferences.textColor),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () => ref.read(readingPreferencesProvider.notifier)
                            .applyPreset(ReadingPreferences.lightPreset),
                        child: const Text('Light'),
                      ),
                      ElevatedButton(
                        onPressed: () => ref.read(readingPreferencesProvider.notifier)
                            .applyPreset(ReadingPreferences.darkPreset),
                        child: const Text('Dark'),
                      ),
                      ElevatedButton(
                        onPressed: () => ref.read(readingPreferencesProvider.notifier)
                            .applyPreset(ReadingPreferences.sepiaPreset),
                        child: const Text('Sepia'),
                      ),
                      ElevatedButton(
                        onPressed: () => ref.read(readingPreferencesProvider.notifier)
                            .applyPreset(ReadingPreferences.oceanPreset),
                        child: const Text('Ocean'),
                      ),
                      ElevatedButton(
                        onPressed: () => ref.read(readingPreferencesProvider.notifier)
                            .applyPreset(ReadingPreferences.forestPreset),
                        child: const Text('Forest'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Divider(height: 32),
            
            // Typography Test
            _buildSection(
              context,
              'Typography',
              Column(
                children: [
                  Text(
                    'Font Size: ${preferences.fontSize.toInt()}px',
                    style: TextStyle(color: preferences.textColor),
                  ),
                  Slider(
                    value: preferences.fontSize,
                    min: 12,
                    max: 32,
                    divisions: 20,
                    label: preferences.fontSize.toInt().toString(),
                    onChanged: (value) {
                      ref.read(readingPreferencesProvider.notifier)
                          .setFontSize(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Line Height: ${preferences.lineHeight.toStringAsFixed(1)}',
                    style: TextStyle(color: preferences.textColor),
                  ),
                  Slider(
                    value: preferences.lineHeight,
                    min: 1.0,
                    max: 2.5,
                    divisions: 15,
                    label: preferences.lineHeight.toStringAsFixed(1),
                    onChanged: (value) {
                      ref.read(readingPreferencesProvider.notifier)
                          .setLineHeight(value);
                    },
                  ),
                ],
              ),
            ),
            
            const Divider(height: 32),
            
            // Sample Text Preview
            _buildSection(
              context,
              'Preview',
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: preferences.margins.horizontal,
                  vertical: preferences.margins.vertical,
                ),
                decoration: BoxDecoration(
                  color: preferences.backgroundColor,
                  border: Border.all(color: preferences.accentColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Đây là đoạn văn mẫu để test typography. '
                  'Font size, line height, và letter spacing đều có thể tùy chỉnh. '
                  'Theme presets cũng thay đổi màu background và text color.',
                  style: TextStyle(
                    color: preferences.textColor,
                    fontSize: preferences.fontSize,
                    height: preferences.lineHeight,
                    letterSpacing: preferences.letterSpacing,
                  ),
                ),
              ),
            ),
            
            const Divider(height: 32),
            
            // Chapter Navigation Test
            _buildSection(
              context,
              'Chapter Navigation',
              Column(
                children: [
                  Text(
                    'Current Chapter: ${currentChapterIndex + 1}',
                    style: TextStyle(
                      color: preferences.textColor,
                      fontSize: preferences.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(chapterNavigationProvider.notifier).previousChapter();
                        },
                        icon: const Icon(Icons.chevron_left),
                        label: const Text('Previous'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(chapterNavigationProvider.notifier).nextChapter();
                        },
                        icon: const Icon(Icons.chevron_right),
                        label: const Text('Next'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _initializeSampleChapters(ref),
                    child: const Text('Initialize Sample Chapters'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Reset Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(readingPreferencesProvider.notifier)
                      .applyPreset(ReadingPreferences.lightPreset);
                  ref.read(readingModeProvider.notifier)
                      .setMode(ReadingMode.standard);
                  ref.read(controlsVisibilityProvider.notifier).show();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: preferences.accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
  
  void _initializeSampleChapters(WidgetRef ref) {
    final sampleChapters = [
      const Chapter(
        id: '1',
        title: 'Chương 1: Mở đầu',
        content: 'Nội dung chương 1...',
        chapterNumber: 1,
        estimatedDuration: Duration(minutes: 15),
      ),
      const Chapter(
        id: '2',
        title: 'Chương 2: Khởi hành',
        content: 'Nội dung chương 2...',
        chapterNumber: 2,
        estimatedDuration: Duration(minutes: 20),
      ),
      const Chapter(
        id: '3',
        title: 'Chương 3: Cuộc gặp gỡ',
        content: 'Nội dung chương 3...',
        chapterNumber: 3,
        estimatedDuration: Duration(minutes: 18),
      ),
      const Chapter(
        id: '4',
        title: 'Chương 4: Bí mật',
        content: 'Nội dung chương 4...',
        chapterNumber: 4,
        estimatedDuration: Duration(minutes: 25),
      ),
      const Chapter(
        id: '5',
        title: 'Chương 5: Kết thúc',
        content: 'Nội dung chương 5...',
        chapterNumber: 5,
        estimatedDuration: Duration(minutes: 30),
      ),
    ];
    
    ref.read(chapterNavigationProvider.notifier).loadChapters(sampleChapters);
  }
}
