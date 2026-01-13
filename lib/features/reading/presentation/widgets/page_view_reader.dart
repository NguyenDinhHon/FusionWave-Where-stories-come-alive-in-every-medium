import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../data/models/chapter_model.dart';

/// Page view reader widget với page flip animations
class PageViewReader extends ConsumerStatefulWidget {
  final ChapterModel chapter;
  final VoidCallback? onNextChapter;
  final VoidCallback? onPreviousChapter;
  final bool hasNext;
  final bool hasPrevious;
  
  const PageViewReader({
    super.key,
    required this.chapter,
    this.onNextChapter,
    this.onPreviousChapter,
    this.hasNext = true,
    this.hasPrevious = true,
  });

  @override
  ConsumerState<PageViewReader> createState() => _PageViewReaderState();
}

class _PageViewReaderState extends ConsumerState<PageViewReader>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late double _fontSize;
  late double _lineHeight;
  late double _margin;
  String _theme = AppConstants.themeLight;
  int _currentPage = 0;
  List<String> _pages = [];
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _splitContentIntoPages();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSettings() async {
    final prefsAsync = ref.read(preferencesServiceProvider);
    prefsAsync.whenData((prefs) {
      setState(() {
        _fontSize = prefs.getFontSize();
        _lineHeight = prefs.getLineHeight();
        _theme = prefs.getTheme();
        _margin = 16.0; // Default margin
      });
    });
  }
  
  void _splitContentIntoPages() {
    // Simple page splitting based on character count
    // In production, use proper text layout measurement
    final content = widget.chapter.content;
    final wordsPerPage = 250; // Approximate words per page
    final words = content.split(' ');
    
    _pages = [];
    for (int i = 0; i < words.length; i += wordsPerPage) {
      final end = (i + wordsPerPage < words.length) 
          ? i + wordsPerPage 
          : words.length;
      _pages.add(words.sublist(i, end).join(' '));
    }
    
    if (_pages.isEmpty) {
      _pages = [content];
    }
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
    return Container(
      color: _getBackgroundColor(),
      child: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Tap left side to go previous, right side to go next
              final screenWidth = MediaQuery.of(context).size.width;
              final tapX = (context.findRenderObject() as RenderBox?)
                  ?.localToGlobal(Offset.zero)
                  .dx;
              
              if (tapX != null) {
                if (tapX < screenWidth / 3) {
                  // Left side - previous
                  if (_currentPage > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else if (widget.hasPrevious && widget.onPreviousChapter != null) {
                    widget.onPreviousChapter!();
                  }
                } else if (tapX > screenWidth * 2 / 3) {
                  // Right side - next
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else if (widget.hasNext && widget.onNextChapter != null) {
                    widget.onNextChapter!();
                  }
                }
              }
            },
            child: Container(
              padding: EdgeInsets.all(_margin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chapter title
                  Text(
                    widget.chapter.title,
                    style: TextStyle(
                      fontSize: _fontSize * 1.2,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(),
                    ),
                  ),
                  if (widget.chapter.subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.chapter.subtitle!,
                      style: TextStyle(
                        fontSize: _fontSize * 0.9,
                        color: _getTextColor().withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  
                  // Page content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _pages[index],
                        style: TextStyle(
                          fontSize: _fontSize,
                          height: _lineHeight,
                          color: _getTextColor(),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Page indicator
                  Center(
                    child: Text(
                      'Page ${index + 1} of ${_pages.length}',
                      style: TextStyle(
                        color: _getTextColor().withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

