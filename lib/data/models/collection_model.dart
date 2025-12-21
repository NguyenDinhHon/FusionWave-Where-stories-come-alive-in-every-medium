import 'package:cloud_firestore/cloud_firestore.dart';

/// Collection model for organizing books
class CollectionModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final List<String> bookIds;
  final String? coverImageUrl;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  CollectionModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.bookIds = const [],
    this.coverImageUrl,
    this.isPublic = false,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Create from Firestore document
  factory CollectionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollectionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      bookIds: List<String>.from(data['bookIds'] ?? []),
      coverImageUrl: data['coverImageUrl'],
      isPublic: data['isPublic'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'bookIds': bookIds,
      'coverImageUrl': coverImageUrl,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
  
  // Create copy with updated fields
  CollectionModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<String>? bookIds,
    String? coverImageUrl,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      bookIds: bookIds ?? this.bookIds,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

