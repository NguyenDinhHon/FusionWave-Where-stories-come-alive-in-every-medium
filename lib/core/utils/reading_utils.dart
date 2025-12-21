/// Reading utilities
class ReadingUtils {
  // Average reading speed: 200-250 words per minute
  static const int averageWordsPerMinute = 200;
  
  /// Calculate reading time in minutes from word count
  static int calculateReadingTime(String content) {
    final wordCount = content.split(RegExp(r'\s+')).length;
    return (wordCount / averageWordsPerMinute).ceil();
  }
  
  /// Calculate word count
  static int getWordCount(String content) {
    if (content.isEmpty) return 0;
    return content.split(RegExp(r'\s+')).length;
  }
  
  /// Calculate estimated time remaining based on scroll position
  static int? calculateTimeRemaining({
    required double scrollPosition,
    required double maxScroll,
    required int totalReadingTimeMinutes,
  }) {
    if (maxScroll <= 0) return null;
    
    final progress = scrollPosition / maxScroll;
    final remainingProgress = 1.0 - progress;
    return (totalReadingTimeMinutes * remainingProgress).ceil();
  }
  
  /// Format reading time
  static String formatReadingTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'}';
      }
      return '$hours ${hours == 1 ? 'hour' : 'hours'} $mins min';
    }
  }
}

