import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/reading_provider.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../data/models/chapter_model.dart';
import '../../../../data/models/book_model.dart';
import '../widgets/reading_settings_dialog.dart';
import '../widgets/reading_progress_indicator.dart';
import '../widgets/page_view_reader.dart';
import '../../../bookmark/presentation/widgets/add_bookmark_dialog.dart';
import '../../../audio/presentation/widgets/mini_audio_player.dart';

/// Enhanced ReadingPage with animations and features
class EnhancedReadingPage extends ConsumerStatefulWidget {
  final String bookId;
  final String? chapterId;

  const EnhancedReadingPage({
    super.key,
    required this.bookId,
    this.chapterId,
  });

  @override
  ConsumerState<EnhancedReadingPage> createState() => _EnhancedReadingPageState();
}

class _EnhancedReadingPageState extends ConsumerState<EnhancedReadingPage> {
  int _currentChapterNumber = 1;
  ChapterModel? _currentChapter;
  BookModel? _book;
  double _fontSize = 16.0;
  double _lineHeight = 1.6;
  double _margin = 16.0;
  String _theme = AppConstants.themeLight;
  String _readingMode = AppConstants.readingModeScroll;
  bool _showProgress = true;
  bool _showAudioPlayer = false;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    if (widget.chapterId != null) {
      _loadChapterById(widget.chapterId!);
    } else {
      _loadFirstChapter();
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSettings() async {
    final prefsAsync = ref.read(preferencesServiceProvider);
    await prefsAsync.whenData((prefs) {
      setState(() {
        _fontSize = prefs.getFontSize();
        _lineHeight = prefs.getLineHeight();
        _theme = prefs.getTheme();
        _readingMode = prefs.getReadingMode();
      });
    });
  }
  
  Future<void> _loadChapterById(String chapterId) async {
    final chapterAsync = ref.read(chapterByIdProvider(chapterId));
    chapterAsync.whenData((chapter) {
      if (chapter != null) {
        setState(() {
          _currentChapter = chapter;
          _currentChapterNumber = chapter.chapterNumber;
        });
        _updateReadingProgress();
        _scrollToTop();
      }
    });
  }
  
  Future<void> _loadFirstChapter() async {
    final chaptersAsync = ref.read(chaptersByBookIdProvider(widget.bookId));
    chaptersAsync.whenData((chapters) {
      if (chapters.isNotEmpty) {
        setState(() {
          _currentChapter = chapters.first;
          _currentChapterNumber = chapters.first.chapterNumber;
        });
        _updateReadingProgress();
        _scrollToTop();
      }
    });
  }
  
  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
  
  Future<void> _updateReadingProgress() async {
    if (_currentChapter == null || _book == null) return;
    
    final controller = ref.read(readingControllerProvider);
    await controller.updateReadingProgress(
      bookId: widget.bookId,
      currentPage: _currentChapter!.pageNumber ?? 0,
      currentChapter: _currentChapterNumber,
      totalPages: _book!.totalPages,
      totalChapters: _book!.totalChapters,
    );
  }
  
  Future<void> _loadNextChapter() async {
    if (_currentChapter == null) return;
    
    final controller = ref.read(readingControllerProvider);
    final nextChapter = await controller.getNextChapter(
      widget.bookId,
      _currentChapterNumber,
    );
    
    if (nextChapter != null) {
      setState(() {
        _currentChapter = nextChapter;
        _currentChapterNumber = nextChapter.chapterNumber;
      });
      _updateReadingProgress();
      _scrollToTop();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No more chapters')),
        );
      }
    }
  }
  
  Future<void> _loadPreviousChapter() async {
    if (_currentChapter == null) return;
    
    final controller = ref.read(readingControllerProvider);
    final prevChapter = await controller.getPreviousChapter(
      widget.bookId,
      _currentChapterNumber,
    );
    
    if (prevChapter != null) {
      setState(() {
        _currentChapter = prevChapter;
        _currentChapterNumber = prevChapter.chapterNumber;
      });
      _updateReadingProgress();
      _scrollToTop();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This is the first chapter')),
        );
      }
    }
  }
  
  void _showReadingSettings() {
    showDialog(
      context: context,
      builder: (context) => ReadingSettingsDialog(
        previewText: _currentChapter?.content ?? '',
      ),
    ).then((_) {
      _loadSettings(); // Reload settings after dialog closes
    });
  }
  
  void _showAddBookmarkDialog() {
    if (_currentChapter == null || _book == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AddBookmarkDialog(
        bookId: widget.bookId,
        chapterId: _currentChapter!.id,
        chapterNumber: _currentChapterNumber,
        pageNumber: _currentChapter!.pageNumber,
      ),
    );
  }
  
  double _calculateProgress() {
    if (_book == null) return 0.0;
    return (_currentChapterNumber / _book!.totalChapters).clamp(0.0, 1.0);
  }
  
  Color _getBackgroundColor() {
    switch (_theme) {
      case AppConstants.themeDark:
        return Colors.grey[900]!;
      case AppConstants.themeSepia:
        return const Color(0xFFF4E4BC);
      default:
        return Colors.white;
    }
  }
  
  Color _getTextColor() {
    switch (_theme) {
      case AppConstants.themeDark:
        return Colors.white;
      case AppConstants.themeSepia:
        return const Color(0xFF5C4033);
      default:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookByIdProvider(widget.bookId));
    
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentChapter?.title ?? 'Reading',
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_book != null)
              Text(
                '${_currentChapterNumber} / ${_book!.totalChapters}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
          ],
        ),
        actions: [
          // Reading mode toggle
          IconButton(
            icon: Icon(
              _readingMode == AppConstants.readingModePage
                  ? Icons.view_column
                  : Icons.view_agenda,
            ),
            tooltip: _readingMode == AppConstants.readingModePage
                ? 'Switch to Scroll Mode'
                : 'Switch to Page Mode',
            onPressed: () async {
              final newMode = _readingMode == AppConstants.readingModePage
                  ? AppConstants.readingModeScroll
                  : AppConstants.readingModePage;
              await ref.read(readingModeProvider.notifier).setReadingMode(newMode);
              setState(() => _readingMode = newMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: _currentChapter != null ? _showAddBookmarkDialog : null,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showReadingSettings,
          ),
        ],
        bottom: _showProgress && _book != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: ReadingProgressIndicator(
                  progress: _calculateProgress(),
                  height: 4,
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: bookAsync.when(
        data: (book) {
          _book = book;
          
          if (_currentChapter == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Reading mode: Scroll or Page view
          if (_readingMode == AppConstants.readingModePage) {
            return PageViewReader(
              chapter: _currentChapter!,
              onNextChapter: _loadNextChapter,
              onPreviousChapter: _currentChapterNumber > 1 ? _loadPreviousChapter : null,
              hasNext: true,
              hasPrevious: _currentChapterNumber > 1,
            );
          } else {
            // Scroll view mode
            return AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.all(_margin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chapter title
                        Text(
                          _currentChapter!.title,
                          style: TextStyle(
                            fontSize: _fontSize * 1.5,
                            fontWeight: FontWeight.bold,
                            color: _getTextColor(),
                            height: _lineHeight,
                          ),
                        ),
                        if (_currentChapter!.subtitle != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _currentChapter!.subtitle!,
                            style: TextStyle(
                              fontSize: _fontSize * 1.1,
                              color: _getTextColor().withOpacity(0.7),
                              height: _lineHeight,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        
                        // Chapter content
                        Text(
                          _currentChapter!.content,
                          style: TextStyle(
                            fontSize: _fontSize,
                            height: _lineHeight,
                            color: _getTextColor(),
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // Chapter navigation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AnimatedButton(
                              text: 'Previous',
                              icon: Icons.arrow_back,
                              onPressed: _currentChapterNumber > 1
                                  ? _loadPreviousChapter
                                  : null,
                              backgroundColor: Colors.grey[300],
                              textColor: Colors.black87,
                            ),
                            Text(
                              'Chapter $_currentChapterNumber',
                              style: TextStyle(
                                color: _getTextColor().withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            AnimatedButton(
                              text: 'Next',
                              icon: Icons.arrow_forward,
                              iconPosition: IconPosition.right,
                              onPressed: _loadNextChapter,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(bookByIdProvider(widget.bookId)),
        ),
          ),
        ),
          // Mini Audio Player
          if (_showAudioPlayer && _book?.audioUrl != null)
            _buildMiniAudioPlayer(context, ref),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: _currentChapterNumber > 1
                    ? _loadPreviousChapter
                    : null,
                color: _getTextColor(),
              ),
            IconButton(
              icon: Icon(
                _showAudioPlayer ? Icons.audiotrack : Icons.play_arrow,
                color: _showAudioPlayer 
                    ? Theme.of(context).primaryColor 
                    : _getTextColor(),
              ),
              onPressed: () {
                if (_book?.audioUrl != null) {
                  setState(() => _showAudioPlayer = !_showAudioPlayer);
                }
              },
            ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: _loadNextChapter,
                color: _getTextColor(),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _showReadingSettings,
                color: _getTextColor(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMiniAudioPlayer(BuildContext context, WidgetRef ref) {
    if (_book == null || _currentChapter == null) return const SizedBox();
    
    // Get chapters for playlist
    final chaptersAsync = ref.watch(chaptersByBookIdProvider(widget.bookId));
    
    return chaptersAsync.when(
      data: (chapters) {
        // Filter chapters with audio URLs
        final audioChapters = chapters.where((ch) => ch.audioUrl != null).toList();
        if (audioChapters.isEmpty) return const SizedBox();
        
        // Create playlist
        final playlist = audioChapters.map((ch) => ch.audioUrl!).toList();
        final currentIndex = audioChapters.indexWhere(
          (ch) => ch.id == _currentChapter!.id,
        );
        
        return MiniAudioPlayer(
          title: _currentChapter!.title,
          playlist: playlist,
          initialIndex: currentIndex >= 0 ? currentIndex : 0,
          onExpand: () {
            // TODO: Show full audio player dialog
          },
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}

