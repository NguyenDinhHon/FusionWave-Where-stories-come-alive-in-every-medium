/// Reading display modes
enum ReadingMode {
  /// Full screen immersive mode with auto-hide controls
  immersive,
  
  /// Standard mode with visible headers and controls
  standard,
  
  /// Split mode for landscape - text + controls side by side
  split,
}

extension ReadingModeExtension on ReadingMode {
  String get displayName {
    switch (this) {
      case ReadingMode.immersive:
        return 'Immersive';
      case ReadingMode.standard:
        return 'Standard';
      case ReadingMode.split:
        return 'Split';
    }
  }
  
  String get description {
    switch (this) {
      case ReadingMode.immersive:
        return 'Full screen, auto-hide controls';
      case ReadingMode.standard:
        return 'Classic reading with headers';
      case ReadingMode.split:
        return 'Text + controls (landscape)';
    }
  }
}
