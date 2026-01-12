import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/image_with_placeholder.dart';
import '../../../../data/models/book_model.dart';

/// Dark theme book card với 2 layouts: horizontal và vertical
class DarkBookCard extends StatelessWidget {
  final BookModel book;
  final bool isHorizontal;
  final double? progress;
  final String? status;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;
  final String? actionLabel;

  const DarkBookCard({
    super.key,
    required this.book,
    this.isHorizontal = false,
    this.progress,
    this.status,
    this.onTap,
    this.onActionTap,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return isHorizontal
        ? _buildHorizontalCard(context)
        : _buildVerticalCard(context);
  }

  // Horizontal layout cho Continue Reading
  Widget _buildHorizontalCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section: Image and Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover với Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: book.coverImageUrl != null
                        ? ImageWithPlaceholder(
                            imageUrl: book.coverImageUrl!,
                            width: 100,
                            height: 150,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(8),
                            errorWidget: Container(
                              width: 100,
                              height: 150,
                              color: AppColors.darkSurface,
                              child: const Icon(Icons.book, color: Colors.grey, size: 40),
                            ),
                          )
                        : Container(
                            width: 100,
                            height: 150,
                            color: AppColors.darkSurface,
                            child: const Icon(Icons.book, color: Colors.grey, size: 40),
                          ),
                  ),
                  // Status Badge
                  if (status != null)
                    Positioned(top: 4, left: 4, child: _buildStatusBadge(status!)),
                ],
              ),
              const SizedBox(width: 16),

              // Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      book.title,
                      style: const TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Author
                    if (book.authors.isNotEmpty)
                      Text(
                        book.authors.join(', '),
                        style: const TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),

                    // Rating
                    if (book.averageRating != null && book.averageRating! > 0)
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              index < book.averageRating!.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: AppColors.ratingColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            book.averageRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.darkTextSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),

                    // Progress Bar
                    if (progress != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progress',
                            style: TextStyle(
                              color: AppColors.darkTextTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(progress! * 100).toInt()}%',
                            style: const TextStyle(
                              color: AppColors.badgeReading,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.darkBorder,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.badgeReading,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Action Button at Bottom
          if (actionLabel != null && onActionTap != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onActionTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getActionColor(actionLabel!),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Vertical layout cho Book Sections
  Widget _buildVerticalCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.push('/book/${book.id}'),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: book.coverImageUrl != null
                  ? ImageWithPlaceholder(
                      imageUrl: book.coverImageUrl!,
                      width: 140,
                      height: 200,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(8),
                      errorWidget: Container(
                        width: 140,
                        height: 200,
                        color: AppColors.darkSurface,
                        child: const Icon(Icons.book, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 140,
                      height: 200,
                      color: AppColors.darkSurface,
                      child: const Icon(Icons.book, color: Colors.grey),
                    ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              book.title,
              style: const TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Author
            if (book.authors.isNotEmpty)
              Text(
                book.authors.join(', '),
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    switch (status.toLowerCase()) {
      case 'reading':
        badgeColor = AppColors.badgeReading;
        break;
      case 'completed':
        badgeColor = AppColors.badgeCompleted;
        break;
      case 'new':
        badgeColor = AppColors.badgeNew;
        break;
      default:
        badgeColor = AppColors.badgeWantToRead;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getActionColor(String label) {
    if (label.toLowerCase().contains('continue') ||
        label.toLowerCase().contains('reading')) {
      return AppColors.actionSuccess;
    } else if (label.toLowerCase().contains('again')) {
      return AppColors.actionPrimary;
    } else {
      return AppColors.darkTextSecondary;
    }
  }
}
