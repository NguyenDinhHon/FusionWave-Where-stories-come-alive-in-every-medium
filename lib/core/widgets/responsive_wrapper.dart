import 'package:flutter/material.dart';
import '../constants/app_breakpoints.dart';
import '../constants/app_spacing.dart';

/// Responsive wrapper widget that adapts layout based on screen size
class ResponsiveWrapper extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveWrapper({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (AppBreakpoints.isLargeDesktop(width) && largeDesktop != null) {
      return largeDesktop!;
    } else if (AppBreakpoints.isDesktop(width) && desktop != null) {
      return desktop!;
    } else if (AppBreakpoints.isTablet(width) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// Responsive value builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, double width) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return builder(context, width);
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = AppBreakpoints.responsiveValue<EdgeInsets>(
      width: width,
      mobile: mobile ?? AppSpacing.paddingL,
      tablet: tablet ?? AppSpacing.paddingXL,
      desktop: desktop ?? AppSpacing.paddingXXL,
    );
    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Responsive grid columns
int getResponsiveGridColumns(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return AppBreakpoints.gridColumns(width);
}

/// Responsive padding value
double getResponsivePadding(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return AppBreakpoints.padding(width);
}

/// Responsive font size multiplier
double getResponsiveFontMultiplier(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return AppBreakpoints.fontSizeMultiplier(width);
}

/// Responsive container with max width
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final responsiveMaxWidth = maxWidth ?? 
        AppBreakpoints.responsiveValue<double>(
          width: width,
          mobile: double.infinity,
          tablet: 900,
          desktop: 1200,
          largeDesktop: 1400,
        );
    final responsivePadding = padding ?? 
        EdgeInsets.symmetric(
          horizontal: getResponsivePadding(context),
        );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: responsiveMaxWidth,
        ),
        child: Padding(
          padding: responsivePadding,
          child: child,
        ),
      ),
    );
  }
}

