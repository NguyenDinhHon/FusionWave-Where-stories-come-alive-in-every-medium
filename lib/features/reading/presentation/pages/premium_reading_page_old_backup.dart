import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/reading_provider.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../data/models/chapter_model.dart';
import '../../../../data/models/book_model.dart';
import '../widgets/reading_settings_dialog.dart';
import '../widgets/reading_progress_indicator.dart';
import '../widgets/page_view_reader.dart';
import '../widgets/chapter_list_drawer.dart';
import '../widgets/reading_progress_info.dart';
import '../widgets/inline_commentable_text.dart';
import '../../../bookmark/presentation/widgets/add_bookmark_dialog.dart';
import '../../../audio/presentation/widgets/mini_audio_player.dart';
import '../../../social/presentation/providers/social_provider.dart';
import '../../../social/presentation/providers/chapter_like_provider.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/utils/reading_utils.dart';

/// Premium Reading Page với design giống Wattpad & Waka
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

class _PremiumReadingPageState extends ConsumerState<PremiumReadingPage> {
  int _currentChapterNumber = 1;
  ChapterModel? _currentChapter;
  BookModel? _book;
  double _fontSize = 16.0;
  double _lineHeight = 1.6;
  double _margin = 16.0;
  String _theme = AppConstants.themeLight;
  String _readingMode = AppConstants.readingModeScroll;
  bool _showControls = false;
  bool _showAudioPlayer = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _timeRemainingMinutes;
  int? _readingSpeed;
  
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
  
  void _updateReadingStats() {
    if (_currentChapter == null) return;
    
    // Calculate reading time
    final readingTime = _currentChapter!.estimatedReadingTimeMinutes ??
        ReadingUtils.calculateReadingTime(_currentChapter!.content);
    
    // Calculate time remaining based on scroll position
    if (_scrollController.hasClients) {
      final position = _scrollController.position.pixels;
      final maxScroll = _scrollController.position.maxScrollExtent;
      _timeRemainingMinutes = ReadingUtils.calculateTimeRemaining(
        scrollPosition: position,
        maxScroll: maxScroll,
        totalReadingTimeMinutes: readingTime,
      );
    } else {
      _timeRemainingMinutes = readingTime;
    }
    
    // Calculate reading speed (simplified - in production, track actual reading)
    final wordCount = ReadingUtils.getWordCount(_currentChapter!.content);
    if (readingTime > 0) {
      _readingSpeed = (wordCount / readingTime).round();
    }
    
    setState(() {});
  }
  
  void _onChapterSelected(ChapterModel chapter) {
    setState(() {
      _currentChapter = chapter;
      _currentChapterNumber = chapter.chapterNumber;
    });
    _updateReadingProgress();
    _scrollToTop();
    _updateReadingStats();
  }
  
  void _showChapterList() {
    _scaffoldKey.currentState?.openEndDrawer();
  }
  
  void _showJumpToChapterDialog() {
    final chapterController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jump to Chapter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _book != null
                  ? 'Enter chapter number (1-${_book!.totalChapters}):'
                  : 'Enter chapter number:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: chapterController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Chapter Number',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          InteractiveButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
            isOutlined: true,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          InteractiveButton(
            label: 'Go',
            icon: Icons.arrow_forward,
            onPressed: () {
              final chapterNum = int.tryParse(chapterController.text);
              if (chapterNum != null && 
                  chapterNum >= 1 && 
                  _book != null && 
                  chapterNum <= _book!.totalChapters) {
                // Load chapter by number
                final chaptersAsync = ref.read(chaptersByBookIdProvider(widget.bookId));
                chaptersAsync.whenData((chapters) {
                  final chapter = chapters.firstWhere(
                    (c) => c.chapterNumber == chapterNum,
                    orElse: () => chapters.first,
                  );
                  _onChapterSelected(chapter);
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _book != null
                          ? 'Please enter a number between 1 and ${_book!.totalChapters}'
                          : 'Invalid chapter number',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
  
  Future<void> _shareChapter() async {
    if (_currentChapter == null || _book == null) return;
    
    final shareService = ShareService();
    await shareService.shareQuote(
      quote: _currentChapter!.content.length > 200
          ? '${_currentChapter!.content.substring(0, 200)}...'
          : _currentChapter!.content,
      bookTitle: _book!.title,
      author: _book!.authors.isNotEmpty ? _book!.authors.first : null,
    );
  }
  
  void _navigateToComments() {
    context.push('/book/${widget.bookId}/comments?chapterId=${_currentChapter?.id}');
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
        _updateReadingStats();
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
        _updateReadingStats();
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
      _loadSettings();
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
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookByIdProvider(widget.bookId));
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _getBackgroundColor(),
      endDrawer: _currentChapter != null && _book != null
          ? ChapterListDrawer(
              bookId: widget.bookId,
              currentChapterNumber: _currentChapterNumber,
              onChapterSelected: _onChapterSelected,
            )
          : null,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _getBackgroundColor(),
        leading: InteractiveIconButton(
          icon: Icons.arrow_back,
          iconColor: _getTextColor(),
          size: 40,
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentChapter?.title ?? 'Reading',
              style: TextStyle(
                fontSize: 16,
                color: _getTextColor(),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_book != null)
              Text(
                'Chapter ${_currentChapterNumber} of ${_book!.totalChapters}',
                style: TextStyle(
                  fontSize: 12,
                  color: _getTextColor().withOpacity(0.7),
                ),
              ),
          ],
        ),
        actions: [
          // Chapter list
          InteractiveIconButton(
            icon: Icons.menu_book,
            iconColor: _getTextColor(),
            size: 40,
            onPressed: _showChapterList,
            tooltip: 'Chapter List',
          ),
          // Reading mode toggle
          InteractiveIconButton(
            icon: _readingMode == AppConstants.readingModePage
                ? Icons.view_column
                : Icons.view_agenda,
            iconColor: _getTextColor(),
            size: 40,
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
          // Bookmark
          InteractiveIconButton(
            icon: Icons.bookmark_border,
            iconColor: _getTextColor(),
            size: 40,
            onPressed: _currentChapter != null ? _showAddBookmarkDialog : null,
            tooltip: 'Add Bookmark',
          ),
          // Settings
          InteractiveIconButton(
            icon: Icons.settings,
            iconColor: _getTextColor(),
            size: 40,
            onPressed: _showReadingSettings,
            tooltip: 'Reading Settings',
          ),
        ],
        bottom: _book != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: ReadingProgressIndicator(
                  progress: _calculateProgress(),
                  height: 4,
                ),
              )
            : null,
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            // Reading content
            bookAsync.when(
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
                  // Scroll view mode với premium design
                  return AnimationConfiguration.staggeredList(
                    position: 0,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification is ScrollUpdateNotification) {
                              _updateReadingStats();
                            }
                            return false;
                          },
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: EdgeInsets.all(_margin),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Chapter title với premium style
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: _getTextColor().withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentChapter!.title,
                                      style: TextStyle(
                                        fontSize: _fontSize * 1.8,
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
                                          fontSize: _fontSize * 1.2,
                                          color: _getTextColor().withOpacity(0.7),
                                          height: _lineHeight,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // Chapter content với premium typography và inline comments
                              Builder(
                                builder: (context) {
                                  final content = _currentChapter!.content;
                                  
                                  // Check if content is empty
                                  if (content.isEmpty) {
                                    return Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.orange.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            size: 48,
                                            color: Colors.orange[700],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No content available',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: _getTextColor(),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'This chapter does not have any content yet.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: _getTextColor().withOpacity(0.7),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  
                                  // Use InlineCommentableText for scroll mode
                                  return InlineCommentableText(
                                    text: content,
                                    bookId: widget.bookId,
                                    chapterId: _currentChapter!.id,
                                    textStyle: TextStyle(
                                      fontSize: _fontSize,
                                      height: _lineHeight,
                                      color: _getTextColor(),
                                      letterSpacing: 0.5,
                                    ),
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 48),
                              
                              // Chapter navigation buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  PremiumButton(
                                    label: 'Previous',
                                    icon: Icons.arrow_back,
                                    isOutlined: true,
                                    color: _getTextColor().withOpacity(0.1) == Colors.white
                                        ? Colors.blue
                                        : _getTextColor(),
                                    onPressed: _currentChapterNumber > 1 ? _loadPreviousChapter : null,
                                  ),
                                  PremiumButton(
                                    label: 'Next',
                                    icon: Icons.arrow_forward,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue,
                                        Colors.blue.withOpacity(0.8),
                                      ],
                                    ),
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
                    ),
                  );
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    PremiumButton(
                      label: 'Retry',
                      onPressed: () {
                        ref.invalidate(bookByIdProvider(widget.bookId));
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Reading progress info (always visible at bottom)
            if (_currentChapter != null && _book != null && !_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ReadingProgressInfo(
                  progress: _calculateProgress(),
                  currentPage: _currentChapter!.pageNumber ?? 0,
                  totalPages: _book!.totalPages,
                  timeRemainingMinutes: _timeRemainingMinutes,
                  readingSpeed: _readingSpeed,
                ),
              ),
            
            // Quick controls overlay (hiện khi tap)
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor().withOpacity(0.95),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Social actions row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Like button
                            if (_currentChapter != null)
                              Builder(
                                builder: (context) {
                                  final isLikedAsync = ref.watch(chapterLikedProvider(_currentChapter!.id));
                                  final likeCountAsync = ref.watch(chapterLikeCountProvider(_currentChapter!.id));
                                  
                                  return isLikedAsync.when(
                                    data: (isLiked) {
                                      return likeCountAsync.when(
                                        data: (likeCount) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InteractiveIconButton(
                                                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                                                iconColor: isLiked ? Colors.red : _getTextColor(),
                                                size: 40,
                                                onPressed: () async {
                                                  try {
                                                    await ref.read(socialControllerProvider).toggleChapterLike(_currentChapter!.id);
                                                    ref.invalidate(chapterLikedProvider(_currentChapter!.id));
                                                    ref.invalidate(chapterLikeCountProvider(_currentChapter!.id));
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(isLiked ? 'Unliked' : 'Liked!'),
                                                          duration: const Duration(seconds: 1),
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text('Error: $e')),
                                                      );
                                                    }
                                                  }
                                                },
                                                tooltip: isLiked ? 'Unlike' : 'Like',
                                              ),
                                              if (likeCount > 0)
                                                Text(
                                                  '$likeCount',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: _getTextColor().withOpacity(0.7),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                        loading: () => InteractiveIconButton(
                                          icon: Icons.favorite_border,
                                          iconColor: _getTextColor(),
                                          size: 40,
                                          onPressed: null,
                                          tooltip: 'Like',
                                        ),
                                        error: (_, __) => InteractiveIconButton(
                                          icon: Icons.favorite_border,
                                          iconColor: _getTextColor(),
                                          size: 40,
                                          onPressed: null,
                                          tooltip: 'Like',
                                        ),
                                      );
                                    },
                                    loading: () => InteractiveIconButton(
                                      icon: Icons.favorite_border,
                                      iconColor: _getTextColor(),
                                      size: 40,
                                      onPressed: null,
                                      tooltip: 'Like',
                                    ),
                                    error: (_, __) => InteractiveIconButton(
                                      icon: Icons.favorite_border,
                                      iconColor: _getTextColor(),
                                      size: 40,
                                      onPressed: null,
                                      tooltip: 'Like',
                                    ),
                                  );
                                },
                              ),
                            // Comment button
                            InteractiveIconButton(
                              icon: Icons.comment_outlined,
                              iconColor: _getTextColor(),
                              size: 40,
                              onPressed: _navigateToComments,
                              tooltip: 'Comments',
                            ),
                            // Share button
                            InteractiveIconButton(
                              icon: Icons.share,
                              iconColor: _getTextColor(),
                              size: 40,
                              onPressed: _shareChapter,
                              tooltip: 'Share',
                            ),
                            // Jump to chapter
                            InteractiveIconButton(
                              icon: Icons.numbers,
                              iconColor: _getTextColor(),
                              size: 40,
                              onPressed: _showJumpToChapterDialog,
                              tooltip: 'Jump to Chapter',
                            ),
                          ],
                        ),
                        const Divider(height: 1),
                        // Navigation row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InteractiveIconButton(
                              icon: Icons.skip_previous,
                              iconColor: _getTextColor(),
                              size: 40,
                              onPressed: _currentChapterNumber > 1 ? _loadPreviousChapter : null,
                              tooltip: 'Previous Chapter',
                            ),
                            InteractiveIconButton(
                              icon: Icons.bookmark_border,
                              iconColor: _getTextColor(),
                              size: 40,
                              onPressed: _showAddBookmarkDialog,
                              tooltip: 'Bookmark',
                            ),
                            InteractiveIconButton(
                              icon: Icons.settings,
                              iconColor: _getTextColor(),
                              size: 40,
                              onPressed: _showReadingSettings,
                              tooltip: 'Settings',
                            ),
                            InteractiveIconButton(
                              icon: Icons.skip_next,
                              iconColor: _getTextColor(),
                              size: 40,
                              onPressed: _loadNextChapter,
                              tooltip: 'Next Chapter',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Audio player (nếu có)
            if (_showAudioPlayer && _currentChapter != null)
              Positioned(
                bottom: _showControls ? 80 : 0,
                left: 0,
                right: 0,
                child: MiniAudioPlayer(
                  title: _currentChapter!.title,
                  audioUrl: _currentChapter!.audioUrl,
                  initialIndex: _currentChapterNumber - 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

