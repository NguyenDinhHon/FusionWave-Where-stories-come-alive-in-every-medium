import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/reading_preferences.dart';

part 'reading_preferences_provider.g.dart';

@riverpod
class ReadingPreferencesNotifier extends _$ReadingPreferencesNotifier {
  @override
  ReadingPreferences build() => ReadingPreferences.lightPreset;
  
  // Font size
  void increaseFontSize() {
    state = state.copyWith(
      fontSize: (state.fontSize + 2).clamp(12.0, 32.0),
    );
  }
  
  void decreaseFontSize() {
    state = state.copyWith(
      fontSize: (state.fontSize - 2).clamp(12.0, 32.0),
    );
  }
  
  void setFontSize(double size) {
    state = state.copyWith(fontSize: size.clamp(12.0, 32.0));
  }
  
  void updateFontSize(double size) {
    state = state.copyWith(fontSize: size.clamp(12.0, 32.0));
  }
  
  void setFontFamily(String family) {
    state = state.copyWith(fontFamily: family);
  }
  
  void updateFontFamily(String family) {
    state = state.copyWith(fontFamily: family);
  }
  
  // Line height
  void setLineHeight(double height) {
    state = state.copyWith(
      lineHeight: height.clamp(1.0, 2.5),
    );
  }
  
  void updateLineHeight(double height) {
    state = state.copyWith(
      lineHeight: height.clamp(1.0, 2.5),
    );
  }
  
  // Letter spacing
  void setLetterSpacing(double spacing) {
    state = state.copyWith(
      letterSpacing: spacing.clamp(0.0, 2.0),
    );
  }
  
  void updateLetterSpacing(double spacing) {
    state = state.copyWith(
      letterSpacing: spacing.clamp(0.0, 2.0),
    );
  }
  
  void setParagraphSpacing(double spacing) {
    state = state.copyWith(paragraphSpacing: spacing);
  }
  
  // Colors
  void setBackgroundColor(Color color) {
    state = state.copyWith(backgroundColor: color);
  }
  
  void setTextColor(Color color) {
    state = state.copyWith(textColor: color);
  }
  
  void setAccentColor(Color color) {
    state = state.copyWith(accentColor: color);
  }
  
  // Layout
  void setTextAlignment(TextAlign alignment) {
    state = state.copyWith(textAlign: alignment);
  }
  
  void updateTextAlign(TextAlign alignment) {
    state = state.copyWith(textAlign: alignment);
  }
  
  void setMargins(double horizontal, double vertical) {
    state = state.copyWith(
      margins: state.margins.copyWith(
        horizontal: horizontal,
        vertical: vertical,
      ),
    );
  }
  
  void updateMarginHorizontal(double value) {
    state = state.copyWith(
      margins: state.margins.copyWith(horizontal: value),
    );
  }
  
  void updateMarginVertical(double value) {
    state = state.copyWith(
      margins: state.margins.copyWith(vertical: value),
    );
  }
  
  // Reset to defaults
  void resetToDefaults() {
    state = ReadingPreferences.lightPreset;
  }
  
  // Preset themes
  void applyPreset(ReadingPreferences preset) {
    state = preset;
  }
}
