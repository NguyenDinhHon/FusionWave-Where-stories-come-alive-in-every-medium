import 'package:cloud_firestore/cloud_firestore.dart';

/// Follow model
class FollowModel {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;
  
  FollowModel({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });
  
  // Create from Firestore document
  factory FollowModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FollowModel(
      id: doc.id,
      followerId: data['followerId'] ?? '',
      followingId: data['followingId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'followerId': followerId,
      'followingId': followingId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

