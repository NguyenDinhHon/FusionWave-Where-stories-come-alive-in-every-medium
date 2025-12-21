import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reading_provider.dart';
import '../../../home/presentation/providers/book_provider.dart';
import '../../../../data/models/chapter_model.dart';
import '../../../../data/models/book_model.dart';

class ReadingPage extends ConsumerStatefulWidget {
  final String bookId;
  final String? chapterId;

  const ReadingPage({
    super.key,
    required this.bookId,
    this.chapterId,
  });

  @override
  ConsumerState<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends ConsumerState<ReadingPage> {
  int _currentChapterNumber = 1;
  ChapterModel? _currentChapter;
  BookModel? _book;
  
  @override
  void initState() {
    super.initState();
    if (widget.chapterId != null) {
      _loadChapterById(widget.chapterId!);
    } else {
      _loadFirstChapter();
    }
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
      }
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
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This is the first chapter')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookByIdProvider(widget.bookId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentChapter?.title ?? 'Reading'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // TODO: Implement bookmark
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showReadingOptions(context);
            },
          ),
        ],
      ),
      body: bookAsync.when(
        data: (book) {
          _book = book;
          
          if (_currentChapter == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chapter title
                Text(
                  _currentChapter!.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_currentChapter!.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _currentChapter!.subtitle!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                
                // Chapter content
                Text(
                  _currentChapter!.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.8,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Chapter navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _currentChapterNumber > 1 ? _loadPreviousChapter : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                    Text(
                      'Chapter $_currentChapterNumber of ${book?.totalChapters ?? 0}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    ElevatedButton.icon(
                      onPressed: _loadNextChapter,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          );
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
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: _currentChapterNumber > 1 ? _loadPreviousChapter : null,
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                // TODO: Play audio if available
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: _loadNextChapter,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                _showReadingOptions(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showReadingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Font Size'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show font size options
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_line_spacing),
              title: const Text('Line Height'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show line height options
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show theme options
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

