import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/chapter.dart';
import '../providers/current_chapter_provider.dart';
import '../providers/reading_preferences_provider.dart';
import '../widgets/chapter_list_sheet.dart';
import '../widgets/reading_settings_panel.dart';
import '../widgets/theme_preset_selector.dart';
import '../widgets/font_selector.dart';

/// Test page cho Phase 2 - UI Widgets
/// Cho phép test từng widget độc lập và kết hợp
class ReadingPhase2TestPage extends ConsumerStatefulWidget {
  const ReadingPhase2TestPage({super.key});

  @override
  ConsumerState<ReadingPhase2TestPage> createState() =>
      _ReadingPhase2TestPageState();
}

class _ReadingPhase2TestPageState
    extends ConsumerState<ReadingPhase2TestPage> {
  @override
  void initState() {
    super.initState();
    // Add sample chapters for testing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chapterNavigationProvider.notifier)
          .loadChapters(_generateSampleChapters());
    });
  }

  List<Chapter> _generateSampleChapters() {
    return List.generate(15, (index) {
      return Chapter(
        id: 'chapter-${index + 1}',
        title: 'Chương ${index + 1}: ${_getChapterTitle(index)}',
        content: _getChapterContent(index),
        chapterNumber: index + 1,
        estimatedDuration: Duration(minutes: 15 + (index * 2)),
      );
    });
  }

  String _getChapterTitle(int index) {
    const titles = [
      'Khởi đầu hành trình',
      'Cuộc gặp gỡ định mệnh',
      'Bí mật được hé lộ',
      'Thử thách đầu tiên',
      'Người bạn đồng hành',
      'Vượt qua thử thách',
      'Chân lý ẩn giấu',
      'Đối mặt với quá khứ',
      'Quyết định quan trọng',
      'Trận chiến lớn',
      'Thất bại và học hỏi',
      'Phục hồi và trở lại',
      'Hiểu biết mới',
      'Hướng tới đỉnh cao',
      'Kết thúc và khởi đầu mới',
    ];
    return titles[index % titles.length];
  }

  String _getChapterContent(int index) {
    return '''
Đây là nội dung của chương ${index + 1}.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.
    '''.trim();
  }

  @override
  Widget build(BuildContext context) {
    final currentChapter = ref.watch(currentChapterProvider);
    final prefs = ref.watch(readingPreferencesProvider);
    final currentIndex = ref.watch(chapterNavigationProvider);
    final chapters = ref.watch(chaptersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 2: UI Widgets Test'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Container(
        color: prefs.backgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              // Status bar
              _buildStatusBar(context, currentChapter, currentIndex, chapters),

              const Divider(height: 1),

              // Content preview
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: prefs.margins.horizontal,
                    vertical: prefs.margins.vertical,
                  ),
                  child: currentChapter != null
                      ? _buildContentPreview(currentChapter, prefs)
                      : _buildNoContentPlaceholder(context),
                ),
              ),

              const Divider(height: 1),

              // Theme preset selector
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: ThemePresetSelector(),
              ),

              const Divider(height: 1),

              // Font selector
              Padding(
                padding: const EdgeInsets.all(20),
                child: FontSelector(),
              ),

              const Divider(height: 1),

              // Action buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(
    BuildContext context,
    Chapter? currentChapter,
    int currentIndex,
    List<Chapter> chapters,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentChapter?.title ?? 'Không có chương',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Chương ${currentIndex + 1}/${chapters.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: currentIndex > 0
                    ? () {
                        ref
                            .read(chapterNavigationProvider.notifier)
                            .previousChapter();
                      }
                    : null,
                tooltip: 'Chương trước',
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: currentIndex < chapters.length - 1
                    ? () {
                        ref
                            .read(chapterNavigationProvider.notifier)
                            .nextChapter();
                      }
                    : null,
                tooltip: 'Chương sau',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentPreview(Chapter chapter, prefs) {
    return Text(
      chapter.content,
      style: TextStyle(
        fontFamily: prefs.fontFamily,
        fontSize: prefs.fontSize,
        height: prefs.lineHeight,
        letterSpacing: prefs.letterSpacing,
        color: prefs.textColor,
      ),
      textAlign: prefs.textAlign,
    );
  }

  Widget _buildNoContentPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có nội dung',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chapter list button
          ElevatedButton.icon(
            onPressed: () => showChapterListSheet(context),
            icon: const Icon(Icons.list_rounded),
            label: const Text('Mở Chapter List Sheet'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 12),

          // Settings panel button
          ElevatedButton.icon(
            onPressed: () => showReadingSettingsPanel(context),
            icon: const Icon(Icons.settings),
            label: const Text('Mở Settings Panel'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundColor:
                  Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),

          const SizedBox(height: 12),

          // Info text
          Text(
            'Phase 2 Widgets:\n'
            '✅ Chapter List Bottom Sheet\n'
            '✅ Reading Settings Panel\n'
            '✅ Theme Preset Selector\n'
            '✅ Font Selector',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
