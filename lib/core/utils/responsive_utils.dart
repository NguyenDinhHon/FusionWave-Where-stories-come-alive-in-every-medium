import 'package:flutter/material.dart';

/// Common responsive helpers for admin UI
class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1100;
  }

  static double pagePadding(BuildContext context) =>
      isMobile(context) ? 16 : 24;

  static int gridCountForWidth(
    double width, {
    double minItemWidth = 240,
    int maxCount = 4,
  }) {
    final calculated = (width / minItemWidth).floor();
    return calculated.clamp(1, maxCount);
  }

  static double maxContentWidth(BuildContext context) =>
      isMobile(context) ? double.infinity : 1200;
}
