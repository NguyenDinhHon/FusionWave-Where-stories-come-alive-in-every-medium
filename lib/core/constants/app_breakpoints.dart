/// Responsive breakpoints for consistent layout
class AppBreakpoints {
  AppBreakpoints._(); // Private constructor to prevent instantiation

  // Breakpoint values
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1800;

  // Helper methods
  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < tablet;
  static bool isDesktop(double width) => width >= tablet && width < desktop;
  static bool isLargeDesktop(double width) => width >= desktop;

  // Responsive value helper
  static T responsiveValue<T>({
    required double width,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop(width) && largeDesktop != null) {
      return largeDesktop;
    } else if (isDesktop(width) && desktop != null) {
      return desktop;
    } else if (isTablet(width) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  // Grid columns based on breakpoint
  static int gridColumns(double width) {
    if (isMobile(width)) return 2;
    if (isTablet(width)) return 3;
    if (isDesktop(width)) return 4;
    return 5; // largeDesktop
  }

  // Padding based on breakpoint
  static double padding(double width) {
    if (isMobile(width)) return 16;
    if (isTablet(width)) return 24;
    return 32; // desktop+
  }

  // Font size multiplier based on breakpoint
  static double fontSizeMultiplier(double width) {
    if (isMobile(width)) return 0.9;
    if (isTablet(width)) return 1.0;
    return 1.1; // desktop+
  }
}

