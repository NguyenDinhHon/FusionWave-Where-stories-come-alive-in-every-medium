import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../../../../data/models/book_model.dart';

// Phase 1: Providers & Models
import '../../domain/models/chapter.dart';
import '../providers/reading_mode_provider.dart';
import '../providers/reading_preferences_provider.dart';
import '../providers/current_chapter_provider.dart';

// Phase 2: Widgets
import '../widgets/chapter_list_sheet.dart';
import '../widgets/reading_settings_panel.dart';

// Firebase data provider
import '../providers/reading_provider.dart';

/// Enhanced Reading Page - Simple, Clean, Beautiful
/// Integrates Phase 1 (Models & Providers) + Phase 2 (UI Widgets)
class PremiumReadingPage extends ConsumerStatefulWidget {
  final String bookId;
  final String? chapterId;

  const PremiumReadingPage({
    super.key,
    required this.bookId,
    this.chapterId,
  });

  @override
  ConsumerState<PremiumReadingPage> createState() => _PremiumReadingPageState();
}

class _PremiumReadingPageState extends ConsumerState<PremiumReadingPage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _controlsAnimationController;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    
    // Controls animation
    _controlsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
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
    if (_scrollController.position.isScrollingNotifier.value) {
      if (!_isScrolling) {
        setState(() => _isScrolling = true);
        _hideControls();
      }
    } else {
      if (_isScrolling) {
        setState(() => _isScrolling = false);
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
  
  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChapterListSheet(),
    );
  }
  
  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReadingSettingsPanel(),
    );
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
    
    // Load chapters when data available
    ref.listen(chaptersByBookIdProvider(widget.bookId), (previous, next) {
      next.whenData((chapterModels) {
        // Convert ChapterModel to Chapter (Phase 1 model)
        final loadedChapters = chapterModels.map((cm) => Chapter(
          id: cm.id,
          title: cm.title,
          chapterNumber: cm.chapterNumber,
          content: cm.content,
          estimatedDuration: cm.estimatedReadingTimeMinutes != null 
              ? Duration(minutes: cm.estimatedReadingTimeMinutes!)
              : null,
        )).toList();
        
        // Only load if chapters changed
        if (chapters.isEmpty || chapters.length != loadedChapters.length) {
          ref.read(chapterNavigationProvider.notifier).loadChapters(loadedChapters);
          
          // If specific chapter requested, navigate to it
          if (widget.chapterId != null && currentChapter == null) {
            final index = loadedChapters.indexWhere((c) => c.id == widget.chapterId);
            if (index >= 0) {
              ref.read(chapterNavigationProvider.notifier).jumpToChapter(index);
            }
          }
        }
      });
    });
    
    return bookAsync.when(
      data: (book) => _buildReader(
        book: book,
        currentChapter: currentChapter,
        chapters: chapters,
        controlsVisible: controlsVisible,
        prefs: prefs,
        mode: mode,
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
  
  Widget _buildReader({
    required BookModel? book,
    required Chapter? currentChapter,
    required List<Chapter> chapters,
    required bool controlsVisible,
    required dynamic prefs,
    required dynamic mode,
  }) {
    if (book == null || currentChapter == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
            // Main Content - Tappable to toggle controls
            GestureDetector(
              onTap: _toggleControls,
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
  
  Widget _buildTopBar(BookModel book, Chapter chapter, bool visible, Color textColor) {
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
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0),
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
                          color: Colors.white.withOpacity(0.7),
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
    return Positioned(
      right: 16,
      bottom: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chapter List Button
          FloatingActionButton.small(
            heroTag: 'chapters',
            onPressed: _showChapterList,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.list_rounded,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            tooltip: 'Chapters',
          ),
          
          const SizedBox(height: 12),
          
          // Settings Button
          FloatingActionButton.small(
            heroTag: 'settings',
            onPressed: _showSettings,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: Icon(
              Icons.tune_rounded,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }
  
  Widget _buildChapterEndActions(List<Chapter> chapters) {
    final currentIndex = ref.watch(chapterNavigationProvider);
    final currentChapter = ref.watch(currentChapterProvider);
    
    if (currentChapter == null || chapters.isEmpty) return const SizedBox.shrink();
    
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
                    ref.read(chapterNavigationProvider.notifier).previousChapter();
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
              leading: const Icon(Icons.bookmark_add_outlined),
              title: const Text('Add Bookmark'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Add bookmark
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Share
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
}
