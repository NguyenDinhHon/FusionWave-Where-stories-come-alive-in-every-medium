import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../../../../data/models/book_model.dart';

// Phase 1: Providers & Models
import '../../domain/models/chapter.dart';
import '../../domain/models/reading_preferences.dart';
import '../providers/reading_mode_provider.dart';
import '../providers/reading_preferences_provider.dart';
import '../providers/current_chapter_provider.dart';

// Phase 2: Widgets
import '../widgets/chapter_list_sheet.dart';
import '../widgets/reading_settings_panel.dart';

// Firebase data provider
import '../providers/reading_provider.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../../../data/repositories/library_repository.dart';

/// Enhanced Reading Page - Simple, Clean, Beautiful
/// Integrates Phase 1 (Models & Providers) + Phase 2 (UI Widgets)
class ReadingPage extends ConsumerStatefulWidget {
  final String bookId;
  final String? chapterId;

  const ReadingPage({super.key, required this.bookId, this.chapterId});

  @override
  ConsumerState<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends ConsumerState<ReadingPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _controlsAnimationController;
  double _lastScrollOffset = 0;
  bool _hasInitializedChapter = false; // Track if we've initialized the chapter
  bool _hasMarkedCurrentChapterComplete =
      false; // Track if current chapter is marked complete

  @override
  void initState() {
    super.initState();

    // Controls animation
    _controlsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward(); // Start visible

    // Auto-hide controls on scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controlsAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;
    final delta = currentOffset - _lastScrollOffset;

    // Hide controls when scrolling down >50px
    if (delta > 50 && _controlsAnimationController.value > 0) {
      _hideControls();
    }
    // Show controls when scrolling up
    else if (delta < -20 && _controlsAnimationController.value == 0) {
      _showControls();
    }

    _lastScrollOffset = currentOffset;

    // Check if scrolled to 90% for chapter completion
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (maxScroll > 0) {
        final scrollPercentage = currentScroll / maxScroll;

        // Mark complete when scrolled to 90%
        if (scrollPercentage >= 0.9 && !_hasMarkedCurrentChapterComplete) {
          _markCurrentChapterComplete();
        }
      }
    }
  }

  void _showControls() {
    _controlsAnimationController.forward();
    ref.read(controlsVisibilityProvider.notifier).show();
  }

  void _hideControls() {
    _controlsAnimationController.reverse();
    ref.read(controlsVisibilityProvider.notifier).hide();
  }

  void _toggleControls() {
    final isVisible = ref.read(controlsVisibilityProvider);
    if (isVisible) {
      _hideControls();
    } else {
      _showControls();
    }
  }

  Future<void> _markCurrentChapterComplete() async {
    final currentChapter = ref.read(currentChapterProvider);
    if (currentChapter == null) return;

    setState(() {
      _hasMarkedCurrentChapterComplete = true;
    });

    try {
      final repository = ref.read(libraryRepositoryProvider);
      final chapters = ref.read(chaptersListProvider);

      // Check if book is in library, if not add it
      var libraryItem = await repository.getLibraryItemByBookId(widget.bookId);
      if (libraryItem == null) {
        await repository.addToLibrary(widget.bookId, status: 'reading');
      }

      // 1. Mark chapter as completed
      await repository.markChapterCompleted(
        bookId: widget.bookId,
        chapterId: currentChapter.id,
      );

      // 2. Get updated library item
      libraryItem = await repository.getLibraryItemByBookId(widget.bookId);
      final completedCount = libraryItem?.completedChapters.length ?? 0;

      // 3. Calculate new progress
      final progress = chapters.isNotEmpty
          ? completedCount / chapters.length
          : 0.0;

      // 4. Update progress
      await repository.updateReadingProgress(
        bookId: widget.bookId,
        currentPage: 0,
        currentChapter: currentChapter.chapterNumber,
        progress: progress,
      );

      // 5. Check if all chapters completed
      await repository.checkAndUpdateCompletionStatus(
        bookId: widget.bookId,
        totalChapters: chapters.length,
      );

      // Refresh library provider
      ref.invalidate(libraryItemByBookIdProvider(widget.bookId));
    } catch (e) {
      print('Failed to mark chapter complete: $e');
    }
  }

  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChapterListSheet(),
    );
  }

  void _showSettings() {
    final prefs = ref.read(readingPreferencesProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Text(
                'Cài đặt nhanh',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              // Font Size Slider
              _buildSlider(
                label: 'Cỡ chữ',
                value: prefs.fontSize,
                min: 12,
                max: 32,
                divisions: 20,
                onChanged: (value) {
                  ref
                      .read(readingPreferencesProvider.notifier)
                      .updateFontSize(value);
                },
              ),

              // Line Height Slider
              _buildSlider(
                label: 'Khoảng cách dòng',
                value: prefs.lineHeight,
                min: 1.0,
                max: 2.5,
                divisions: 15,
                onChanged: (value) {
                  ref
                      .read(readingPreferencesProvider.notifier)
                      .updateLineHeight(value);
                },
              ),

              const SizedBox(height: 16),

              // Theme Presets
              Text('Chủ đề', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildThemeCard(
                      label: 'Sáng',
                      preset: ReadingPreferences.lightPreset,
                      isSelected:
                          prefs.backgroundColor ==
                          ReadingPreferences.lightPreset.backgroundColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildThemeCard(
                      label: 'Tối',
                      preset: ReadingPreferences.darkPreset,
                      isSelected:
                          prefs.backgroundColor ==
                          ReadingPreferences.darkPreset.backgroundColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildThemeCard(
                      label: 'Sepia',
                      preset: ReadingPreferences.sepiaPreset,
                      isSelected:
                          prefs.backgroundColor ==
                          ReadingPreferences.sepiaPreset.backgroundColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // More Settings Button
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const ReadingSettingsPanel(),
                  );
                },
                child: const Text('Cài đặt nâng cao'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              value.toStringAsFixed(1),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
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

  Widget _buildThemeCard({
    required String label,
    required ReadingPreferences preset,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(readingPreferencesProvider.notifier).applyPreset(preset);
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: preset.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: preset.textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _addBookmark() async {
    final currentChapter = ref.read(currentChapterProvider);
    if (currentChapter == null) return;

    final prefs = await SharedPreferences.getInstance();
    final bookmarkKey = 'bookmarks_${widget.bookId}';

    // Get existing bookmarks
    final bookmarksJson = prefs.getStringList(bookmarkKey) ?? [];

    // Add new bookmark
    final newBookmark = {
      'chapterId': currentChapter.id,
      'chapterTitle': currentChapter.title,
      'chapterNumber': currentChapter.chapterNumber,
      'position': _scrollController.offset.toInt(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    bookmarksJson.add(newBookmark.toString());
    await prefs.setStringList(bookmarkKey, bookmarksJson);

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã lưu bookmark: ${currentChapter.title}'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentChapter = ref.watch(currentChapterProvider);
    final chapters = ref.watch(chaptersListProvider);
    final controlsVisible = ref.watch(controlsVisibilityProvider);
    final prefs = ref.watch(readingPreferencesProvider);
    final mode = ref.watch(readingModeProvider);

    // Get book data
    final bookAsync = ref.watch(bookByIdProvider(widget.bookId));

    // Watch chapters and load them
    final chaptersAsync = ref.watch(chaptersByBookIdProvider(widget.bookId));

    // Handle chapters loading
    return chaptersAsync.when(
      data: (chapterModels) {
        // Convert ChapterModel to Chapter (Phase 1 model)
        final loadedChapters = chapterModels
            .map(
              (cm) => Chapter(
                id: cm.id,
                title: cm.title,
                chapterNumber: cm.chapterNumber,
                content: cm.content,
                estimatedDuration: cm.estimatedReadingTimeMinutes != null
                    ? Duration(minutes: cm.estimatedReadingTimeMinutes!)
                    : null,
              ),
            )
            .toList();

        // Load chapters into provider if not already loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Load chapters list directly without resetting index
          if (chapters.isEmpty || chapters.length != loadedChapters.length) {
            debugPrint(
              '[ReadingPage] Loading ${loadedChapters.length} chapters into provider',
            );
            ref
                .read(chaptersListProvider.notifier)
                .loadChapters(loadedChapters);
          }

          // Only initialize chapter once (not on every rebuild)
          if (!_hasInitializedChapter) {
            _hasInitializedChapter = true;
            debugPrint(
              '[ReadingPage] Initializing chapter. chapterId: ${widget.chapterId}',
            );

            if (widget.chapterId != null) {
              final index = loadedChapters.indexWhere(
                (c) => c.id == widget.chapterId,
              );
              debugPrint('[ReadingPage] Found chapter at index: $index');
              if (index >= 0) {
                debugPrint('[ReadingPage] Jumping to chapter index $index');
                ref
                    .read(chapterNavigationProvider.notifier)
                    .jumpToChapter(index);
                final currentIndex = ref.read(chapterNavigationProvider);
                debugPrint(
                  '[ReadingPage] Current index after jump: $currentIndex',
                );
              } else {
                debugPrint(
                  '[ReadingPage] Chapter ID not found in loaded chapters!',
                );
              }
            } else if (currentChapter == null && loadedChapters.isNotEmpty) {
              // Default to first chapter if no chapter specified
              debugPrint('[ReadingPage] No chapterId, defaulting to chapter 0');
              ref.read(chapterNavigationProvider.notifier).jumpToChapter(0);
            }
          }
        });

        // Now build the reader with book data
        return bookAsync.when(
          data: (book) => _buildReader(
            book: book,
            chapters: chapters.isEmpty ? loadedChapters : chapters,
            controlsVisible: controlsVisible,
            prefs: prefs,
            mode: mode,
          ),
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stack) =>
              Scaffold(body: Center(child: Text('Error loading book: $error'))),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading chapters...'),
            ],
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading chapters: $error'),
              const SizedBox(height: 8),
              Text('Stack: $stack', style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReader({
    required BookModel? book,
    required List<Chapter> chapters,
    required bool controlsVisible,
    required dynamic prefs,
    required dynamic mode,
  }) {
    // Watch current chapter from provider (updates when navigation changes)
    final currentChapter = ref.watch(currentChapterProvider);
    // Watch chapter index to trigger rebuild when navigation changes
    ref.watch(chapterNavigationProvider);

    if (book == null || currentChapter == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Get theme colors from preferences
    final bgColor = prefs.backgroundColor;
    final textColor = prefs.textColor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _getBrightness(bgColor),
        systemNavigationBarColor: bgColor,
        systemNavigationBarIconBrightness: _getBrightness(bgColor),
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            // Main Content - Tappable to toggle controls + Swipe for navigation
            GestureDetector(
              onTap: _toggleControls,
              onHorizontalDragEnd: (details) {
                // Swipe threshold: 350 pixels per second
                final velocity = details.velocity.pixelsPerSecond.dx;
                if (velocity.abs() > 350) {
                  if (velocity > 0) {
                    // Swipe right → Previous chapter
                    final currentIndex = ref.read(chapterNavigationProvider);
                    if (currentIndex > 0) {
                      ref
                          .read(chapterNavigationProvider.notifier)
                          .previousChapter();
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                  } else {
                    // Swipe left → Next chapter
                    final chapters = ref.read(chaptersListProvider);
                    final currentIndex = ref.read(chapterNavigationProvider);
                    if (currentIndex < chapters.length - 1) {
                      ref
                          .read(chapterNavigationProvider.notifier)
                          .nextChapter();
                      setState(() {
                        _hasMarkedCurrentChapterComplete = false;
                      });
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                  }
                }
              },
              behavior: HitTestBehavior.opaque,
              child: SafeArea(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: prefs.margins.horizontal,
                    vertical: prefs.margins.vertical,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top spacing for header
                      SizedBox(height: controlsVisible ? 80 : 24),

                      // Chapter Title
                      Text(
                        currentChapter.title,
                        style: TextStyle(
                          fontSize: prefs.fontSize + 4,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontFamily: prefs.fontFamily,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Chapter Content
                      SelectableText(
                        currentChapter.content,
                        style: TextStyle(
                          fontSize: prefs.fontSize,
                          height: prefs.lineHeight,
                          letterSpacing: prefs.letterSpacing,
                          color: textColor,
                          fontFamily: prefs.fontFamily,
                        ),
                        textAlign: prefs.textAlign,
                      ),

                      const SizedBox(height: 80),

                      // Chapter End Actions
                      _buildChapterEndActions(chapters),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Top Bar (Auto-hide)
            _buildTopBar(book, currentChapter, controlsVisible, textColor),

            // Floating Action Buttons (Always visible)
            _buildFloatingButtons(controlsVisible),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BookModel book,
    Chapter chapter,
    bool visible,
    Color textColor,
  ) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      top: visible ? 0 : -100,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.black.withValues(alpha: 0),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                  tooltip: 'Back',
                ),

                // Book & Chapter Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Chapter ${chapter.chapterNumber}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // More Options
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: _showMoreOptions,
                  tooltip: 'More',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButtons(bool controlsVisible) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      right: 16,
      bottom: controlsVisible ? 80 : 20,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: controlsVisible ? 1.0 : 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bookmark Button
            FloatingActionButton.small(
              heroTag: 'bookmark',
              onPressed: _addBookmark,
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              tooltip: 'Bookmark',
              child: Icon(
                Icons.bookmark_add_outlined,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),

            const SizedBox(height: 12),

            // Chapter List Button
            FloatingActionButton.small(
              heroTag: 'chapters',
              onPressed: _showChapterList,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              tooltip: 'Chapters',
              child: Icon(
                Icons.list_rounded,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(height: 12),

            // Settings Button
            FloatingActionButton.small(
              heroTag: 'settings',
              onPressed: _showSettings,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              tooltip: 'Settings',
              child: Icon(
                Icons.tune_rounded,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterEndActions(List<Chapter> chapters) {
    final currentIndex = ref.watch(chapterNavigationProvider);
    final currentChapter = ref.watch(currentChapterProvider);

    if (currentChapter == null || chapters.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasNext = currentIndex < chapters.length - 1;
    final hasPrev = currentIndex > 0;

    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),

        // Chapter Navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous Chapter
            if (hasPrev)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref
                        .read(chapterNavigationProvider.notifier)
                        .previousChapter();
                    setState(() {
                      _hasMarkedCurrentChapterComplete = false;
                    });
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              )
            else
              const Expanded(child: SizedBox.shrink()),

            const SizedBox(width: 16),

            // Next Chapter
            if (hasNext)
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    ref.read(chapterNavigationProvider.notifier).nextChapter();
                    setState(() {
                      _hasMarkedCurrentChapterComplete = false;
                    });
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next'),
                  iconAlignment: IconAlignment.end,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              )
            else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ],
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () async {
                Navigator.pop(context);
                await _shareBook(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Book Info'),
              onTap: () {
                Navigator.pop(context);
                context.push('/book/${widget.bookId}');
              },
            ),
          ],
        ),
      ),
    );
  }

  Brightness _getBrightness(Color color) {
    return color.computeLuminance() > 0.5 ? Brightness.dark : Brightness.light;
  }

  Future<void> _shareBook(BuildContext context, WidgetRef ref) async {
    final bookAsync = ref.read(bookByIdProvider(widget.bookId));
    final currentChapter = ref.read(currentChapterProvider);

    await bookAsync.when(
      data: (book) async {
        if (book == null) return;

        String shareText = 'Check out "${book.title}" on FusionWave!\n\n';
        if (book.authors.isNotEmpty) {
          shareText += 'By: ${book.authors.join(', ')}\n';
        }
        if (currentChapter != null) {
          shareText += 'Currently reading: ${currentChapter.title}\n';
        }
        shareText += '\nDownload FusionWave to read more!';

        await SharePlus.instance.share(ShareParams(text: shareText));
      },
      loading: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loading book information...')),
        );
      },
      error: (error, stack) async {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      },
    );
  }
}
