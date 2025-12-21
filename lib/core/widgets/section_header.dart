import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_spacing.dart';

/// Section header widget with title and optional "See All" link
class SectionHeader extends StatelessWidget {
  final String title;
  final String? seeAllLabel;
  final VoidCallback? onSeeAll;
  final String? seeAllRoute;
  final IconData? icon;
  final bool showDivider;

  const SectionHeader({
    super.key,
    required this.title,
    this.seeAllLabel,
    this.onSeeAll,
    this.seeAllRoute,
    this.icon,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.paddingHorizontalL,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 24,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppSpacing.spacing8),
                  ],
                  Text(
                    title,
                    style: AppTextStyles.heading2().copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (seeAllLabel != null && (onSeeAll != null || seeAllRoute != null))
                TextButton.icon(
                  onPressed: onSeeAll ?? 
                      (seeAllRoute != null 
                          ? () => context.push(seeAllRoute!)
                          : null),
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
                    label: Text(
                    seeAllLabel!,
                    style: AppTextStyles.body().copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: AppSpacing.paddingHorizontalS,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ),
        if (showDivider) ...[
          SizedBox(height: AppSpacing.spacing8),
          Container(
            margin: AppSpacing.paddingHorizontalL,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  isDark 
                      ? AppColors.borderDark.withOpacity(0.3)
                      : AppColors.borderLight.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
        SizedBox(height: AppSpacing.spacing16),
      ],
    );
  }
}

