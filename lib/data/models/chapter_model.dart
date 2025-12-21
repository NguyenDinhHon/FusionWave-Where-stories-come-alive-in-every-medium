import 'package:cloud_firestore/cloud_firestore.dart';

/// Chapter model
class ChapterModel {
  final String id;
  final String bookId;
  final String title;
  final String? subtitle;
  final String content;
  final int chapterNumber;
  final int? pageNumber;
  final String? audioUrl;
  final String? videoUrl;
  final int? estimatedReadingTimeMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  
  ChapterModel({
    required this.id,
    required this.bookId,
    required this.title,
    this.subtitle,
    required this.content,
    required this.chapterNumber,
    this.pageNumber,
    this.audioUrl,
    this.videoUrl,
    this.estimatedReadingTimeMinutes,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = false,
  });
  
  // Create from Firestore document
  factory ChapterModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChapterModel(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'],
      content: data['content'] ?? '',
      chapterNumber: data['chapterNumber'] ?? 0,
      pageNumber: data['pageNumber'],
      audioUrl: data['audioUrl'],
      videoUrl: data['videoUrl'],
      estimatedReadingTimeMinutes: data['estimatedReadingTimeMinutes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublished: data['isPublished'] ?? false,
    );
  }
  
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'bookId': bookId,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'chapterNumber': chapterNumber,
      'pageNumber': pageNumber,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'estimatedReadingTimeMinutes': estimatedReadingTimeMinutes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublished': isPublished,
    };
  }
  
  // Create copy with updated fields
  ChapterModel copyWith({
    String? id,
    String? bookId,
    String? title,
    String? subtitle,
    String? content,
    int? chapterNumber,
    int? pageNumber,
    String? audioUrl,
    String? videoUrl,
    int? estimatedReadingTimeMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      pageNumber: pageNumber ?? this.pageNumber,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      estimatedReadingTimeMinutes: estimatedReadingTimeMinutes ?? this.estimatedReadingTimeMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}

