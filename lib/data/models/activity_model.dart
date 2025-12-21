import 'package:cloud_firestore/cloud_firestore.dart';

/// Activity model for social feed
class ActivityModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final ActivityType type;
  final String? bookId;
  final String? bookTitle;
  final String? bookCoverUrl;
  final String? chapterId;
  final String? chapterTitle;
  final String? content; // Comment, review, etc.
  final DateTime createdAt;
  
  ActivityModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.type,
    this.bookId,
    this.bookTitle,
    this.bookCoverUrl,
    this.chapterId,
    this.chapterTitle,
    this.content,
    required this.createdAt,
  });
  
  // Create from Firestore document
  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatarUrl: data['userAvatarUrl'],
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => ActivityType.reading,
      ),
      bookId: data['bookId'],
      bookTitle: data['bookTitle'],
      bookCoverUrl: data['bookCoverUrl'],
      chapterId: data['chapterId'],
      chapterTitle: data['chapterTitle'],
      content: data['content'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'type': type.toString().split('.').last,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookCoverUrl': bookCoverUrl,
      'chapterId': chapterId,
      'chapterTitle': chapterTitle,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum ActivityType {
  reading,
  completed,
  rated,
  commented,
  bookmarked,
  shared,
}

