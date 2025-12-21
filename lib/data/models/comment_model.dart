import 'package:cloud_firestore/cloud_firestore.dart';

/// Comment model
class CommentModel {
  final String id;
  final String userId;
  final String bookId;
  final String? chapterId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likes;
  final List<String> likedBy;
  final String? parentCommentId; // For replies
  
  CommentModel({
    required this.id,
    required this.userId,
    required this.bookId,
    this.chapterId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.likes = 0,
    this.likedBy = const [],
    this.parentCommentId,
  });
  
  // Create from Firestore document
  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      bookId: data['bookId'] ?? '',
      chapterId: data['chapterId'],
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      parentCommentId: data['parentCommentId'],
    );
  }
  
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bookId': bookId,
      'chapterId': chapterId,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'likes': likes,
      'likedBy': likedBy,
      'parentCommentId': parentCommentId,
    };
  }
  
  // Create copy with updated fields
  CommentModel copyWith({
    String? id,
    String? userId,
    String? bookId,
    String? chapterId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likes,
    List<String>? likedBy,
    String? parentCommentId,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      parentCommentId: parentCommentId ?? this.parentCommentId,
    );
  }
}

