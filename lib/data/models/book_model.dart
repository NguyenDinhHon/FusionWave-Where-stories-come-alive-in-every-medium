import 'package:cloud_firestore/cloud_firestore.dart';

/// Book model
class BookModel {
  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final String? coverImageUrl;
  final List<String> authors;
  final List<String> categories;
  final List<String> tags;
  final int totalPages;
  final int totalChapters;
  final String? audioUrl;
  final String? videoUrl;
  final double? averageRating;
  final int totalRatings;
  final int totalReads;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? editorId;
  final bool isPublished;
  final String? language;
  final int? estimatedReadingTimeMinutes;
  
  BookModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    this.coverImageUrl,
    this.authors = const [],
    this.categories = const [],
    this.tags = const [],
    this.totalPages = 0,
    this.totalChapters = 0,
    this.audioUrl,
    this.videoUrl,
    this.averageRating,
    this.totalRatings = 0,
    this.totalReads = 0,
    required this.createdAt,
    required this.updatedAt,
    this.editorId,
    this.isPublished = false,
    this.language,
    this.estimatedReadingTimeMinutes,
  });
  
  // Create from Firestore document
  factory BookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookModel(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'],
      description: data['description'],
      coverImageUrl: data['coverImageUrl'],
      authors: List<String>.from(data['authors'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      totalPages: data['totalPages'] ?? 0,
      totalChapters: data['totalChapters'] ?? 0,
      audioUrl: data['audioUrl'],
      videoUrl: data['videoUrl'],
      averageRating: (data['averageRating'] as num?)?.toDouble(),
      totalRatings: data['totalRatings'] ?? 0,
      totalReads: data['totalReads'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      editorId: data['editorId'],
      isPublished: data['isPublished'] ?? false,
      language: data['language'],
      estimatedReadingTimeMinutes: data['estimatedReadingTimeMinutes'],
    );
  }
  
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'authors': authors,
      'categories': categories,
      'tags': tags,
      'totalPages': totalPages,
      'totalChapters': totalChapters,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'totalReads': totalReads,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'editorId': editorId,
      'isPublished': isPublished,
      'language': language,
      'estimatedReadingTimeMinutes': estimatedReadingTimeMinutes,
    };
  }
  
  // Create copy with updated fields
  BookModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    String? coverImageUrl,
    List<String>? authors,
    List<String>? categories,
    List<String>? tags,
    int? totalPages,
    int? totalChapters,
    String? audioUrl,
    String? videoUrl,
    double? averageRating,
    int? totalRatings,
    int? totalReads,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? editorId,
    bool? isPublished,
    String? language,
    int? estimatedReadingTimeMinutes,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      authors: authors ?? this.authors,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      totalPages: totalPages ?? this.totalPages,
      totalChapters: totalChapters ?? this.totalChapters,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      totalReads: totalReads ?? this.totalReads,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      editorId: editorId ?? this.editorId,
      isPublished: isPublished ?? this.isPublished,
      language: language ?? this.language,
      estimatedReadingTimeMinutes: estimatedReadingTimeMinutes ?? this.estimatedReadingTimeMinutes,
    );
  }
}

