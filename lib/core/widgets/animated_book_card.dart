import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/book_model.dart';
import '../constants/app_colors.dart';
import 'interactive_button.dart';
import 'image_with_placeholder.dart';
import '../../features/library/presentation/providers/library_provider.dart';

/// Animated book card widget with quick actions
class AnimatedBookCard extends ConsumerStatefulWidget {
  final BookModel book;
  final VoidCallback? onTap;
  final bool showRating;
  final double? width;
  final double? height;
  final bool showQuickActions;

  const AnimatedBookCard({
    super.key,
    required this.book,
    this.onTap,
    this.showRating = false,
    this.width,
    this.height,
    this.showQuickActions = true,
  });

  @override
  ConsumerState<AnimatedBookCard> createState() => _AnimatedBookCardState();
}

class _AnimatedBookCardState extends ConsumerState<AnimatedBookCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cardWidth = widget.width ?? 140;
    
    final libraryItemAsync = ref.watch(libraryItemByBookIdProvider(widget.book.id));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap ?? () => context.push('/book/${widget.book.id}'),
        child: Container(
          width: cardWidth,
          margin: EdgeInsets.zero, // Margin được xử lý bởi parent (Row trong BookCarousel)
          child: Stack(
            children: [
              // Book Card
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Book Cover
                  Container(
                    width: cardWidth,
                    height: 154,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ImageWithPlaceholder(
                      imageUrl: widget.book.coverImageUrl,
                      width: cardWidth,
                      height: 154,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(8),
                      placeholderIcon: Icons.book,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  SizedBox(
                    height: 36,
                    child: Text(
                      widget.book.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Rating (if enabled)
                  if (widget.showRating && widget.book.averageRating != null) ...[
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 16,
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            widget.book.averageRating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              // Quick Actions Overlay (on hover)
              if (widget.showQuickActions && _isHovered)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Read Now / Continue Reading
                        libraryItemAsync.when(
                          data: (libraryItem) {
                            if (libraryItem != null) {
                              return InteractiveButton(
                                label: 'Tiếp tục đọc',
                                icon: Icons.play_arrow,
                                onPressed: () {
                                  context.push(
                                    '/reading/${widget.book.id}?chapterId=${libraryItem.currentChapter}',
                                  );
                                },
                                gradient: AppColors.primaryGradient,
                                height: 32,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                textColor: Colors.white,
                                iconColor: Colors.white,
                              );
                            } else {
                              return InteractiveButton(
                                label: 'Đọc ngay',
                                icon: Icons.play_arrow,
                                onPressed: () {
                                  context.push('/reading/${widget.book.id}');
                                },
                                gradient: AppColors.primaryGradient,
                                height: 32,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                textColor: Colors.white,
                                iconColor: Colors.white,
                              );
                            }
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => InteractiveButton(
                            label: 'Đọc ngay',
                            icon: Icons.play_arrow,
                            onPressed: () {
                              context.push('/reading/${widget.book.id}');
                            },
                            gradient: AppColors.primaryGradient,
                            height: 32,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            textColor: Colors.white,
                            iconColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Add to Library / Remove from Library
                        libraryItemAsync.when(
                          data: (libraryItem) {
                            if (libraryItem != null) {
                              return InteractiveButton(
                                label: 'Đã có',
                                icon: Icons.check,
                                onPressed: () async {
                                  final controller =
                                      ref.read(libraryControllerProvider);
                                  await controller.removeFromLibrary(
                                    widget.book.id,
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã xóa khỏi thư viện'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                },
                                isOutlined: true,
                                height: 32,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                textColor: Colors.white,
                                iconColor: Colors.white,
                              );
                            } else {
                              return InteractiveButton(
                                label: 'Thêm vào thư viện',
                                icon: Icons.add,
                                onPressed: () async {
                                  final controller =
                                      ref.read(libraryControllerProvider);
                                  await controller.addToLibrary(widget.book.id);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã thêm vào thư viện'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                },
                                isOutlined: true,
                                height: 32,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                textColor: Colors.white,
                                iconColor: Colors.white,
                              );
                            }
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => InteractiveButton(
                            label: 'Thêm vào thư viện',
                            icon: Icons.add,
                            onPressed: () async {
                              final controller =
                                  ref.read(libraryControllerProvider);
                              await controller.addToLibrary(widget.book.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã thêm vào thư viện'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            isOutlined: true,
                            height: 32,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            textColor: Colors.white,
                            iconColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // View Details
                        InteractiveButton(
                          label: 'Chi tiết',
                          icon: Icons.info_outline,
                          onPressed: () {
                            context.push('/book/${widget.book.id}');
                          },
                          isOutlined: true,
                          height: 32,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          textColor: Colors.white,
                          iconColor: Colors.white,
                        ),
                      ],
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
