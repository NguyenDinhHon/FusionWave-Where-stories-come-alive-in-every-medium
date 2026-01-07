import 'package:flutter/material.dart';

/// User reading preferences for customization
class ReadingPreferences {
  // Typography
  final String fontFamily;
  final double fontSize;
  final double lineHeight;
  final double letterSpacing;
  
  // Theme
  final String themePreset; // 'light', 'dark', 'sepia', 'ocean', 'forest'
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;
  
  // Layout
  final double margins;
  final double paragraphSpacing;
  final TextAlign textAlign;
  
  // Behavior
  final bool autoHideControls;
  final bool dimBackground;

  const ReadingPreferences({
    this.fontFamily = 'System',
    this.fontSize = 18.0,
    this.lineHeight = 1.6,
    this.letterSpacing = 0.5,
    this.themePreset = 'light',
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFF2C2C2C),
    this.accentColor = const Color(0xFF4A90E2),
    this.margins = 24.0,
    this.paragraphSpacing = 16.0,
    this.textAlign = TextAlign.left,
    this.autoHideControls = true,
    this.dimBackground = false,
  });

  ReadingPreferences copyWith({
    String? fontFamily,
    double? fontSize,
    double? lineHeight,
    double? letterSpacing,
    String? themePreset,
    Color? backgroundColor,
    Color? textColor,
    Color? accentColor,
    double? margins,
    double? paragraphSpacing,
    TextAlign? textAlign,
    bool? autoHideControls,
    bool? dimBackground,
  }) {
    return ReadingPreferences(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      themePreset: themePreset ?? this.themePreset,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      accentColor: accentColor ?? this.accentColor,
      margins: margins ?? this.margins,
      paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
      textAlign: textAlign ?? this.textAlign,
      autoHideControls: autoHideControls ?? this.autoHideControls,
      dimBackground: dimBackground ?? this.dimBackground,
    );
  }
  
  /// Get TextStyle based on preferences
  TextStyle get textStyle {
    return TextStyle(
      fontFamily: fontFamily == 'System' ? null : fontFamily,
      fontSize: fontSize,
      height: lineHeight,
      letterSpacing: letterSpacing,
      color: textColor,
    );
  }
  
  // ============ THEME PRESETS ============
  
  /// Classic Light theme
  static const lightPreset = ReadingPreferences(
    themePreset: 'light',
    backgroundColor: Colors.white,
    textColor: Color(0xFF2C2C2C),
    accentColor: Color(0xFF4A90E2),
    fontFamily: 'System',
  );
  
  /// Dark Night theme with blue light filter
  static const darkPreset = ReadingPreferences(
    themePreset: 'dark',
    backgroundColor: Color(0xFF1A1A1A),
    textColor: Color(0xFFE8E8E8),
    accentColor: Color(0xFF64B5F6),
    fontFamily: 'Roboto',
  );
  
  /// Sepia Vintage theme
  static const sepiaPreset = ReadingPreferences(
    themePreset: 'sepia',
    backgroundColor: Color(0xFFF4ECD8),
    textColor: Color(0xFF5C4B37),
    accentColor: Color(0xFF8B7355),
    fontFamily: 'Georgia',
  );
  
  /// Ocean Blue theme
  static const oceanPreset = ReadingPreferences(
    themePreset: 'ocean',
    backgroundColor: Color(0xFFF0F8FF),
    textColor: Color(0xFF1C3D5A),
    accentColor: Color(0xFF4A90E2),
    fontFamily: 'System',
  );
  
  /// Forest Green theme
  static const forestPreset = ReadingPreferences(
    themePreset: 'forest',
    backgroundColor: Color(0xFFF0F4E8),
    textColor: Color(0xFF2D4A2B),
    accentColor: Color(0xFF5C8A58),
    fontFamily: 'System',
  );
  
  /// Get preset by name
  static ReadingPreferences getPreset(String name) {
    switch (name) {
      case 'light':
        return lightPreset;
      case 'dark':
        return darkPreset;
      case 'sepia':
        return sepiaPreset;
      case 'ocean':
        return oceanPreset;
      case 'forest':
        return forestPreset;
      default:
        return lightPreset;
    }
  }
  
  /// List of all available presets
  static const List<String> allPresets = [
    'light',
    'dark',
    'sepia',
    'ocean',
    'forest',
  ];
  
  /// Get preset display name
  static String getPresetDisplayName(String preset) {
    switch (preset) {
      case 'light':
        return 'Classic Light';
      case 'dark':
        return 'Dark Night';
      case 'sepia':
        return 'Sepia Vintage';
      case 'ocean':
        return 'Ocean Blue';
      case 'forest':
        return 'Forest Green';
      default:
        return preset;
    }
  }
  
  /// Get preset icon
  static IconData getPresetIcon(String preset) {
    switch (preset) {
      case 'light':
        return Icons.wb_sunny;
      case 'dark':
        return Icons.nightlight_round;
      case 'sepia':
        return Icons.article;
      case 'ocean':
        return Icons.water;
      case 'forest':
        return Icons.eco;
      default:
        return Icons.palette;
    }
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ReadingPreferences &&
        other.fontFamily == fontFamily &&
        other.fontSize == fontSize &&
        other.lineHeight == lineHeight &&
        other.themePreset == themePreset;
  }
  
  @override
  int get hashCode {
    return fontFamily.hashCode ^
        fontSize.hashCode ^
        lineHeight.hashCode ^
        themePreset.hashCode;
  }
}

/// Available font families
class ReadingFonts {
  static const List<String> available = [
    'System',
    'Roboto',
    'Georgia',
    'Merriweather',
    'Open Sans',
  ];
  
  static String getDisplayName(String font) {
    return font;
  }
}
