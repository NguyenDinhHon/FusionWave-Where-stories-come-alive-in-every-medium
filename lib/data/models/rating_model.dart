import 'package:cloud_firestore/cloud_firestore.dart';

/// Rating model
class RatingModel {
  final String id;
  final String userId;
  final String bookId;
  final int rating; // 1-5 stars
  final String? review;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  RatingModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.rating,
    this.review,
    required this.createdAt,
    this.updatedAt,
  });
  
  // Create from Firestore document
  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RatingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      bookId: data['bookId'] ?? '',
      rating: data['rating'] ?? 0,
      review: data['review'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
  
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bookId': bookId,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
  
  // Create copy with updated fields
  RatingModel copyWith({
    String? id,
    String? userId,
    String? bookId,
    int? rating,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RatingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

