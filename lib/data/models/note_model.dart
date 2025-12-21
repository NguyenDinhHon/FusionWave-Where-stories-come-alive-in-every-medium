import 'package:cloud_firestore/cloud_firestore.dart';

/// Note model (for text highlights and annotations)
class NoteModel {
  final String id;
  final String userId;
  final String bookId;
  final String chapterId;
  final int chapterNumber;
  final String highlightedText;
  final String note;
  final int? startPosition;
  final int? endPosition;
  final String? color; // Hex color for highlight
  final DateTime createdAt;
  final DateTime updatedAt;
  
  NoteModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.chapterId,
    required this.chapterNumber,
    required this.highlightedText,
    required this.note,
    this.startPosition,
    this.endPosition,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Create from Firestore document
  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      bookId: data['bookId'] ?? '',
      chapterId: data['chapterId'] ?? '',
      chapterNumber: data['chapterNumber'] ?? 0,
      highlightedText: data['highlightedText'] ?? '',
      note: data['note'] ?? '',
      startPosition: data['startPosition'],
      endPosition: data['endPosition'],
      color: data['color'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bookId': bookId,
      'chapterId': chapterId,
      'chapterNumber': chapterNumber,
      'highlightedText': highlightedText,
      'note': note,
      'startPosition': startPosition,
      'endPosition': endPosition,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
  
  // Create copy with updated fields
  NoteModel copyWith({
    String? id,
    String? userId,
    String? bookId,
    String? chapterId,
    int? chapterNumber,
    String? highlightedText,
    String? note,
    int? startPosition,
    int? endPosition,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      highlightedText: highlightedText ?? this.highlightedText,
      note: note ?? this.note,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

