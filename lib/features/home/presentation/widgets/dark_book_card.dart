import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Book Cover với Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: book.coverImageUrl != null
                    ? Image.network(
                        book.coverImageUrl!,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 120,
                          color: AppColors.darkSurface,
                          child: const Icon(Icons.book, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 120,
                        color: AppColors.darkSurface,
                        child: const Icon(Icons.book, color: Colors.grey),
                      ),
              ),
              // Status Badge
              if (status != null)
                Positioned(top: 4, left: 4, child: _buildStatusBadge(status!)),
            ],
          ),
          const SizedBox(width: 12),

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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 6),

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
                          size: 14,
                          color: AppColors.ratingColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        book.averageRating!.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),

                // Genre/Category
                if (book.categories.isNotEmpty)
                  Text(
                    book.categories.first,
                    style: const TextStyle(
                      color: AppColors.darkTextTertiary,
                      fontSize: 12,
                    ),
                  ),

                const Spacer(),

                // Progress Bar
                if (progress != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          color: AppColors.darkTextTertiary,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '${(progress! * 100).toInt()}%',
                        style: const TextStyle(
                          color: AppColors.badgeReading,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.darkBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.badgeReading,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action Button
          if (actionLabel != null && onActionTap != null) ...[
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onActionTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getActionColor(actionLabel!),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(actionLabel!, style: const TextStyle(fontSize: 12)),
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
                  ? Image.network(
                      book.coverImageUrl!,
                      width: 140,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
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
