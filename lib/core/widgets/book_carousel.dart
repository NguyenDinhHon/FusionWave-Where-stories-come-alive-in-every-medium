import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/book_model.dart';
import '../constants/app_colors.dart';
import 'animated_book_card.dart';
import 'interactive_button.dart';

/// Book carousel widget giống Wattpad - hiển thị 7 card với nút điều hướng
/// Chuyển trang: giữ lại 5 card cuối, thêm 2 card mới
class BookCarousel extends StatefulWidget {
  final List<BookModel> books;
  final String? title;
  final VoidCallback? onSeeAll;
  final int itemsPerPage;
  final double cardWidth; // Width cố định cho mỗi card

  const BookCarousel({
    super.key,
    required this.books,
    this.title,
    this.onSeeAll,
    this.itemsPerPage = 7,
    this.cardWidth = 160.0, // Width cố định - đồng bộ với AnimatedBookCard
  });

  @override
  State<BookCarousel> createState() => _BookCarouselState();
}

class _BookCarouselState extends State<BookCarousel> {
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Tính số trang: mỗi trang mới chỉ thêm 2 card (overlap 5 card)
  int get _totalPages {
    if (widget.books.isEmpty) return 0;
    if (widget.books.length <= widget.itemsPerPage) return 1;
    // Số trang = (tổng số card - 7) / 2 + 1
    return ((widget.books.length - widget.itemsPerPage) / 2).ceil() + 1;
  }

  // Lấy danh sách card cho trang hiện tại
  // Trang 0: card 0-6 (7 card)
  // Trang 1: card 2-8 (giữ lại card 2-6, thêm card 7-8)
  // Trang 2: card 4-10 (giữ lại card 4-8, thêm card 9-10)
  List<BookModel> _getPageBooks(int pageIndex) {
    final startIndex = pageIndex * 2; // Mỗi trang mới bắt đầu từ index + 2
    final endIndex = (startIndex + widget.itemsPerPage).clamp(0, widget.books.length);
    
    if (startIndex >= widget.books.length) {
      return [];
    }
    
    return widget.books.sublist(startIndex, endIndex);
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.books.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (widget.onSeeAll != null)
                  TextButton(
                    onPressed: widget.onSeeAll,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('See All'),
                  ),
              ],
            ),
          ),
        SizedBox(
          height: 300, // Height cố định
          child: Stack(
                children: [
                  // Books grid
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _totalPages,
                    itemBuilder: (context, pageIndex) {
                      final pageBooks = _getPageBooks(pageIndex);
                      
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          // Tính toán cardWidth động dựa trên constraints
                          // Đảm bảo 7 card + spacing vừa với màn hình
                          final spacing = 12.0;
                          final maxCards = widget.itemsPerPage;
                          // Trừ padding horizontal (16px mỗi bên)
                          final availableWidth = constraints.maxWidth - 32;
                          // Tính width cho mỗi card: (availableWidth - spacing giữa các card) / số card
                          final calculatedCardWidth = (availableWidth - (spacing * (maxCards - 1))) / maxCards;
                          // Giới hạn width trong khoảng 140-160 để đảm bảo không quá nhỏ hoặc quá lớn
                          final effectiveCardWidth = calculatedCardWidth.clamp(140.0, widget.cardWidth);
                          
                          // Tính lại số card có thể hiển thị trong không gian thực tế
                          final actualMaxCards = ((availableWidth + spacing) / (effectiveCardWidth + spacing)).floor().clamp(1, pageBooks.length);
                          final displayBooks = pageBooks.take(actualMaxCards).toList();
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(displayBooks.length, (index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: index < displayBooks.length - 1 ? spacing : 0,
                                  ),
                                  child: AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      horizontalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: SizedBox(
                                          width: effectiveCardWidth,
                                          child: AnimatedBookCard(
                                            book: displayBooks[index],
                                            width: effectiveCardWidth,
                                            height: 240,
                                            onTap: () => context.push('/book/${displayBooks[index].id}'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Navigation buttons - căn giữa với card (240px height)
                  if (_totalPages > 1) ...[
                    // Previous button
                    if (_currentPage > 0)
                      Positioned(
                        left: 8,
                        top: 30, // (300 - 240) / 2 = 30px để căn giữa với card
                        height: 240, // Chiều cao của card
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InteractiveIconButton(
                              icon: Icons.chevron_left,
                              iconColor: AppColors.iconLight,
                              size: 40,
                              onPressed: _previousPage,
                              tooltip: 'Previous',
                            ),
                          ),
                        ),
                      ),
                    // Next button - căn giữa với card (240px height)
                    if (_currentPage < _totalPages - 1)
                      Positioned(
                        right: 8,
                        top: 30, // (300 - 240) / 2 = 30px để căn giữa với card
                        height: 240, // Chiều cao của card
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InteractiveIconButton(
                              icon: Icons.chevron_right,
                              iconColor: AppColors.iconLight,
                              size: 40,
                              onPressed: _nextPage,
                              tooltip: 'Next',
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
          ),
        ),
      ],
    );
  }
}
