import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

/// Library item model (user's saved book)
class LibraryItemModel {
  final String id;
  final String userId;
  final String bookId;
  final String status; // reading, completed, want_to_read, dropped
  final int currentPage;
  final int currentChapter;
  final List<String> completedChapters; // List of completed chapter IDs
  final double progress; // 0.0 - 1.0
  final DateTime addedAt;
  final DateTime? lastReadAt;
  final int totalReadingTimeMinutes;
  final bool isDownloaded;
  final bool isBookmarked; // Secondary status

  LibraryItemModel({
    required this.id,
    required this.userId,
    required this.bookId,
    this.status = AppConstants.bookStatusReading,
    this.currentPage = 0,
    this.currentChapter = 1,
    this.completedChapters = const [],
    this.progress = 0.0,
    required this.addedAt,
    this.lastReadAt,
    this.totalReadingTimeMinutes = 0,
    this.isDownloaded = false,
    this.isBookmarked = false,
  });

  // Create from Firestore document
  factory LibraryItemModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      return LibraryItemModel(
        id: doc.id,
        userId: data['userId'] ?? '',
        bookId: data['bookId'] ?? '',
        status: data['status'] ?? AppConstants.bookStatusReading,
        currentPage: data['currentPage'] ?? 0,
        currentChapter: data['currentChapter'] ?? 1,
        completedChapters:
            (data['completedChapters'] as List?)
                ?.map((e) => e?.toString() ?? '')
                .toList() ??
            [],
        progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
        addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        lastReadAt: (data['lastReadAt'] as Timestamp?)?.toDate(),
        totalReadingTimeMinutes: data['totalReadingTimeMinutes'] ?? 0,
        isDownloaded: data['isDownloaded'] ?? false,
        isBookmarked: data['isBookmarked'] ?? false,
      );
    } catch (e) {
      print('Error parsing LibraryItemModel: $e');
      // Return a default model or rethrow depending on needs
      // For now, rethrow to see the error
      rethrow;
    }
  }

  // Check if book is completed
  bool get isCompleted => status == AppConstants.bookStatusCompleted;

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bookId': bookId,
      'status': status,
      'currentPage': currentPage,
      'currentChapter': currentChapter,
      'completedChapters': completedChapters,
      'progress': progress,
      'addedAt': Timestamp.fromDate(addedAt),
      'lastReadAt': lastReadAt != null ? Timestamp.fromDate(lastReadAt!) : null,
      'totalReadingTimeMinutes': totalReadingTimeMinutes,
      'isDownloaded': isDownloaded,
      'isBookmarked': isBookmarked,
    };
  }

  // Create copy with updated fields
  LibraryItemModel copyWith({
    String? id,
    String? userId,
    String? bookId,
    String? status,
    int? currentPage,
    int? currentChapter,
    List<String>? completedChapters,
    double? progress,
    DateTime? addedAt,
    DateTime? lastReadAt,
    int? totalReadingTimeMinutes,
    bool? isDownloaded,
  }) {
    return LibraryItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      currentChapter: currentChapter ?? this.currentChapter,
      completedChapters: completedChapters ?? this.completedChapters,
      progress: progress ?? this.progress,
      addedAt: addedAt ?? this.addedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      totalReadingTimeMinutes:
          totalReadingTimeMinutes ?? this.totalReadingTimeMinutes,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }
}
