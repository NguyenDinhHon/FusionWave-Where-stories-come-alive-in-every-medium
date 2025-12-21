import 'package:cloud_firestore/cloud_firestore.dart';

/// User model
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? preferences;
  final String? fcmToken;
  final bool isProfilePublic;
  final bool isReadingStatsPublic;
  final int readingStreak;
  final DateTime? lastReadingDate;
  
  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = 'user',
    required this.createdAt,
    this.lastLoginAt,
    this.preferences,
    this.fcmToken,
    this.isProfilePublic = true,
    this.isReadingStatsPublic = false,
    this.readingStreak = 0,
    this.lastReadingDate,
  });
  
  // Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'user',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      preferences: data['preferences'] as Map<String, dynamic>?,
      fcmToken: data['fcmToken'],
      isProfilePublic: data['isProfilePublic'] ?? true,
      isReadingStatsPublic: data['isReadingStatsPublic'] ?? false,
      readingStreak: data['readingStreak'] ?? 0,
      lastReadingDate: (data['lastReadingDate'] as Timestamp?)?.toDate(),
    );
  }
  
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'preferences': preferences,
      'fcmToken': fcmToken,
      'isProfilePublic': isProfilePublic,
      'isReadingStatsPublic': isReadingStatsPublic,
      'readingStreak': readingStreak,
      'lastReadingDate': lastReadingDate != null ? Timestamp.fromDate(lastReadingDate!) : null,
    };
  }
  
  // Create copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
    String? fcmToken,
    bool? isProfilePublic,
    bool? isReadingStatsPublic,
    int? readingStreak,
    DateTime? lastReadingDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      fcmToken: fcmToken ?? this.fcmToken,
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      isReadingStatsPublic: isReadingStatsPublic ?? this.isReadingStatsPublic,
      readingStreak: readingStreak ?? this.readingStreak,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
    );
  }
}

