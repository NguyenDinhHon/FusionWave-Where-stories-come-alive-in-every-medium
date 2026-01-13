import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);

  // Secondary Colors
  static const Color secondary = Color(0xFFEC4899); // Pink
  static const Color secondaryDark = Color(0xFFDB2777);
  static const Color secondaryLight = Color(0xFFF472B6);

  // Accent Colors
  static const Color accent = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red

  // Background Colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color backgroundSepia = Color(0xFFF4E4BC);

  // Surface Colors
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceSepia = Color(0xFFE8DCC0);

  // Text Colors - Improved contrast
  static const Color textPrimaryLight = Color(
    0xFF0F172A,
  ); // Dark for light backgrounds
  static const Color textPrimaryDark = Color(
    0xFFF1F5F9,
  ); // Light for dark backgrounds
  static const Color textSecondaryLight = Color(
    0xFF475569,
  ); // Darker grey for better contrast (was 64748B)
  static const Color textSecondaryDark = Color(
    0xFFCBD5E1,
  ); // Lighter grey for better contrast (was 94A3B8)

  // Icon Colors - High contrast
  static const Color iconLight = Color(
    0xFF1E293B,
  ); // Dark for light backgrounds
  static const Color iconDark = Color(0xFFE2E8F0); // Light for dark backgrounds
  static const Color iconSecondaryLight = Color(0xFF475569); // Medium dark
  static const Color iconSecondaryDark = Color(0xFFCBD5E1); // Medium light

  // Border Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // Reading Mode Colors
  static const Color readingHighlight = Color(0xFFFFF59D);
  static const Color bookmarkColor = Color(0xFFFF6B6B);
  static const Color noteColor = Color(0xFF4ECDC4);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);
  static const Color danger = Color(0xFFEF4444);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Surface variants
  static const Color surfaceLightVariant = Color(0xFFF5F5F5);
  static const Color surfaceDarkVariant = Color(0xFF1E1E1E);

  // Primary variants
  static const Color primaryLightVariant = Color(0xFFE3F2FD);
  static const Color primaryDarkVariant = Color(0xFF1565C0);

  // Accent colors
  static const Color accentColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // Additional Gradients
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, Color(0xFFFF5252)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successColor, Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, surfaceLightVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient overlayGradient = LinearGradient(
    colors: [
      Colors.black.withValues(alpha: 0.7),
      Colors.black.withValues(alpha: 0.9),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============================================
  // Dark Theme Colors (New Design)
  // ============================================

  // Main backgrounds
  static const Color darkBackground = Color(0xFF1a1a1a);
  static const Color darkCard = Color(0xFF2d2d2d);
  static const Color darkSurface = Color(0xFF2d2d2d);

  // Text colors for dark theme
  static const Color darkTextPrimary = Color(0xFFffffff);
  static const Color darkTextSecondary = Color(0xFFa0a0a0);
  static const Color darkTextTertiary = Color(0xFF6b6b6b);

  // Borders and dividers
  static const Color darkBorder = Color(0xFF3d3d3d);
  static const Color darkDivider = Color(0xFF2d2d2d);

  // Badge colors
  static const Color badgeReading = Color(0xFF4caf50);
  static const Color badgeCompleted = Color(0xFF2196f3);
  static const Color badgeNew = Color(0xFFff9800);
  static const Color badgeWantToRead = Color(0xFF9c27b0);

  // Action button colors
  static const Color actionPrimary = Color(0xFF4a9eff);
  static const Color actionSuccess = Color(0xFF4caf50);
  static const Color actionWarning = Color(0xFFff9800);

  // Rating color
  static const Color ratingColor = Color(0xFFffa726);
}
