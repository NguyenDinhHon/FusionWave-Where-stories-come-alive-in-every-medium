import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_spacing.dart';
import 'interactive_button.dart';

/// Empty state widget with illustration and message
class EmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final String? lottieAsset;
  final Widget? action;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.lottieAsset,
    this.action,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.iconDark : AppColors.iconLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.paddingXXL,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lottieAsset != null)
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Lottie.asset(
                    lottieAsset!,
                    fit: BoxFit.contain,
                  ),
                )
              else if (icon != null)
                Container(
                  padding: AppSpacing.paddingXL,
                  decoration: BoxDecoration(
                    color: isDark 
                        ? AppColors.surfaceDark.withOpacity(0.5)
                        : AppColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 64,
                    color: iconColor.withOpacity(0.7),
                  ),
                ),
              SizedBox(height: AppSpacing.spacing24),
              Text(
                title,
                style: AppTextStyles.heading3().copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                SizedBox(height: AppSpacing.spacing8),
                Text(
                  message!,
                  style: AppTextStyles.body().copyWith(
                    color: secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (action != null || (actionLabel != null && onAction != null)) ...[
                SizedBox(height: AppSpacing.spacing24),
                action ?? InteractiveButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  icon: Icons.add,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

