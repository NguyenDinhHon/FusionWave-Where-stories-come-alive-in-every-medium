import 'package:flutter/material.dart';

/// Spacing constants for consistent layout
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // Base spacing values
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;
  static const double spacing80 = 80.0;

  // Common padding values
  static const EdgeInsets paddingXS = EdgeInsets.all(spacing4);
  static const EdgeInsets paddingS = EdgeInsets.all(spacing8);
  static const EdgeInsets paddingM = EdgeInsets.all(spacing12);
  static const EdgeInsets paddingL = EdgeInsets.all(spacing16);
  static const EdgeInsets paddingXL = EdgeInsets.all(spacing20);
  static const EdgeInsets paddingXXL = EdgeInsets.all(spacing24);

  // Common margin values
  static const EdgeInsets marginXS = EdgeInsets.all(spacing4);
  static const EdgeInsets marginS = EdgeInsets.all(spacing8);
  static const EdgeInsets marginM = EdgeInsets.all(spacing12);
  static const EdgeInsets marginL = EdgeInsets.all(spacing16);
  static const EdgeInsets marginXL = EdgeInsets.all(spacing20);
  static const EdgeInsets marginXXL = EdgeInsets.all(spacing24);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalS = EdgeInsets.symmetric(horizontal: spacing8);
  static const EdgeInsets paddingHorizontalM = EdgeInsets.symmetric(horizontal: spacing12);
  static const EdgeInsets paddingHorizontalL = EdgeInsets.symmetric(horizontal: spacing16);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: spacing20);
  static const EdgeInsets paddingHorizontalXXL = EdgeInsets.symmetric(horizontal: spacing24);

  // Vertical padding
  static const EdgeInsets paddingVerticalS = EdgeInsets.symmetric(vertical: spacing8);
  static const EdgeInsets paddingVerticalM = EdgeInsets.symmetric(vertical: spacing12);
  static const EdgeInsets paddingVerticalL = EdgeInsets.symmetric(vertical: spacing16);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: spacing20);
  static const EdgeInsets paddingVerticalXXL = EdgeInsets.symmetric(vertical: spacing24);

  // Section spacing
  static const double sectionGap = spacing24;
  static const double sectionGapLarge = spacing32;
  static const double sectionGapXLarge = spacing48;
}

