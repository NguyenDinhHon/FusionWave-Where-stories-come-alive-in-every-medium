import 'package:cloud_firestore/cloud_firestore.dart';

/// Bookmark model
class BookmarkModel {
  final String id;
  final String userId;
  final String bookId;
  final String chapterId;
  final int chapterNumber;
  final int? pageNumber;
  final String? note;
  final String? highlightedText;
  final DateTime createdAt;
  
  BookmarkModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.chapterId,
    required this.chapterNumber,
    this.pageNumber,
    this.note,
    this.highlightedText,
    required this.createdAt,
  });
  
  // Create from Firestore document
  factory BookmarkModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookmarkModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      bookId: data['bookId'] ?? '',
      chapterId: data['chapterId'] ?? '',
      chapterNumber: data['chapterNumber'] ?? 0,
      pageNumber: data['pageNumber'],
      note: data['note'],
      highlightedText: data['highlightedText'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bookId': bookId,
      'chapterId': chapterId,
      'chapterNumber': chapterNumber,
      'pageNumber': pageNumber,
      'note': note,
      'highlightedText': highlightedText,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  
  // Create copy with updated fields
  BookmarkModel copyWith({
    String? id,
    String? userId,
    String? bookId,
    String? chapterId,
    int? chapterNumber,
    int? pageNumber,
    String? note,
    String? highlightedText,
    DateTime? createdAt,
  }) {
    return BookmarkModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      pageNumber: pageNumber ?? this.pageNumber,
      note: note ?? this.note,
      highlightedText: highlightedText ?? this.highlightedText,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

