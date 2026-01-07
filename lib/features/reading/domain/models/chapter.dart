/// Chapter model for book navigation
class Chapter {
  final String id;
  final String title;
  final String content;
  final int chapterNumber;
  final Duration? estimatedDuration;
  final int? wordCount;
  
  const Chapter({
    required this.id,
    required this.title,
    required this.content,
    required this.chapterNumber,
    this.estimatedDuration,
    this.wordCount,
  });
  
  Chapter copyWith({
    String? id,
    String? title,
    String? content,
    int? chapterNumber,
    Duration? estimatedDuration,
    int? wordCount,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      wordCount: wordCount ?? this.wordCount,
    );
  }
  
  /// Format estimated reading time
  String get formattedDuration {
    if (estimatedDuration == null) return '';
    
    final minutes = estimatedDuration!.inMinutes;
    if (minutes < 60) {
      return '$minutes phút';
    }
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    
    return '${hours}h ${remainingMinutes}p';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Chapter &&
        other.id == id &&
        other.title == title &&
        other.chapterNumber == chapterNumber;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ chapterNumber.hashCode;
  }
}
