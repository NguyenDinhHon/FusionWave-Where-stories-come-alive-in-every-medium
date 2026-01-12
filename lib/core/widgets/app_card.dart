import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../constants/app_shadows.dart';

/// App card widget với shadow và animations
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? AppSpacing.marginS,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: AppShadows.shadowMedium,
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: Padding(padding: padding ?? AppSpacing.paddingL, child: child),
        ),
      ),
    );

    return card;
  }
}
