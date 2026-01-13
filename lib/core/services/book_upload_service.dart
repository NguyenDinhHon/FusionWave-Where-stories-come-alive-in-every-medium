import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/book_model.dart';
import '../../data/models/chapter_model.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

/// Service để upload và parse sách
class BookUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user ID for editorId
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Upload book với file và metadata
  Future<BookModel> uploadBook({
    required String title,
    String? subtitle,
    required List<String> authors,
    String? description,
    File? coverImage,
    String? coverImageUrl,
    File? bookFile,
    List<String>? categories,
    List<String>? tags,
    double? rating,
    String? language,
  }) async {
    try {
      final bookId = _firestore.collection(AppConstants.booksCollection).doc().id;
      final now = DateTime.now();

      // Get cover image URL - either from upload or from URL parameter
      String? finalCoverImageUrl = coverImageUrl;
      if (finalCoverImageUrl == null && coverImage != null) {
        finalCoverImageUrl = await _uploadCoverImage(bookId, coverImage);
      }

      // Parse book file và tạo chapters
      List<ChapterModel> chapters = [];
      int totalPages = 0;
      if (bookFile != null) {
        final result = await _parseBookFile(bookId, bookFile);
        chapters = result['chapters'] as List<ChapterModel>;
        totalPages = result['totalPages'] as int;
      }

      // Tạo book document với tất cả các field cần thiết, khớp với database
      final book = BookModel(
        id: bookId,
        title: title,
        subtitle: subtitle, // Optional subtitle
        authors: authors,
        description: description,
        coverImageUrl: finalCoverImageUrl,
        categories: categories ?? [],
        tags: tags ?? [], // Tags from parameter or empty
        totalPages: totalPages,
        totalChapters: chapters.length,
        audioUrl: null, // Optional, not set during upload
        videoUrl: null, // Optional, not set during upload
        averageRating: rating,
        totalRatings: 0, // Initialize to 0
        totalReads: 0, // Initialize to 0
        createdAt: now,
        updatedAt: now,
        editorId: _currentUserId, // Set current user as editor
        isPublished: false, // Draft by default
        language: language ?? 'vi',
        estimatedReadingTimeMinutes: totalPages > 0 
            ? (totalPages * 2).round() // Estimate 2 minutes per page
            : null,
      );

      // Save book to Firestore using toFirestore() to ensure correct format
      final bookData = book.toFirestore();
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .set(bookData);

      // Upload chapters
      for (final chapter in chapters) {
        await _firestore
            .collection(AppConstants.chaptersCollection)
            .doc(chapter.id)
            .set(chapter.toFirestore());
      }

      AppLogger.info('Book uploaded: $bookId');
      return book;
    } catch (e) {
      AppLogger.error('Upload book error', error: e);
      rethrow;
    }
  }

  /// Upload cover image
  Future<String> _uploadCoverImage(String bookId, File imageFile) async {
    try {
      final ref = _storage.ref().child('book_covers/$bookId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      AppLogger.error('Upload cover image error', error: e);
      rethrow;
    }
  }

  /// Parse book file thành chapters
  Future<Map<String, dynamic>> _parseBookFile(String bookId, File file) async {
    try {
      final content = await file.readAsString();
      final extension = file.path.split('.').last.toLowerCase();

      List<ChapterModel> chapters = [];
      int totalPages = 0;

      switch (extension) {
        case 'txt':
        case 'md':
          final result = _parseTextFile(bookId, content);
          chapters = result['chapters'] as List<ChapterModel>;
          totalPages = result['totalPages'] as int;
          break;
        case 'pdf':
          // ignore: todo
          // TODO: Implement PDF parsing - requires pdf package
          throw UnimplementedError('PDF parsing not yet implemented');
        case 'docx':
          // ignore: todo
          // TODO: Implement DOCX parsing - requires docx package
          throw UnimplementedError('DOCX parsing not yet implemented');
        default:
          throw Exception('Unsupported file format: $extension');
      }

      return {
        'chapters': chapters,
        'totalPages': totalPages,
      };
    } catch (e) {
      AppLogger.error('Parse book file error', error: e);
      rethrow;
    }
  }

  /// Parse text file (TXT, MD) thành chapters
  Map<String, dynamic> _parseTextFile(String bookId, String content) {
    final lines = content.split('\n');
    final chapters = <ChapterModel>[];
    final now = DateTime.now();

    // Patterns để detect chapter markers
    final chapterPatterns = [
      RegExp(r'^Chapter\s+(\d+)', caseSensitive: false),
      RegExp(r'^Ch\.\s*(\d+)', caseSensitive: false),
      RegExp(r'^Chương\s+(\d+)', caseSensitive: false),
      RegExp(r'^CHƯƠNG\s+(\d+)', caseSensitive: false),
      RegExp(r'^(\d+)\.', caseSensitive: false),
      RegExp(r'^#+\s+(.+)', caseSensitive: false), // Markdown headers
    ];

    int currentChapterNumber = 0;
    String currentChapterTitle = 'Chapter 1';
    List<String> currentChapterContent = [];
    int totalPages = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Check if this line is a chapter marker
      bool isChapterMarker = false;
      String? chapterTitle;
      int? chapterNumber;

      for (final pattern in chapterPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          isChapterMarker = true;
          if (match.groupCount >= 1) {
            final numStr = match.group(1);
            if (numStr != null && int.tryParse(numStr) != null) {
              chapterNumber = int.parse(numStr);
            }
          }
          chapterTitle = line;
          break;
        }
      }

      // If it's a markdown header, use the header text as title
      if (line.startsWith('#') && !isChapterMarker) {
        final headerMatch = RegExp(r'^#+\s+(.+)').firstMatch(line);
        if (headerMatch != null) {
          isChapterMarker = true;
          chapterTitle = headerMatch.group(1)?.trim() ?? line;
          chapterNumber = (currentChapterNumber + 1);
        }
      }

      if (isChapterMarker && currentChapterContent.isNotEmpty) {
        // Save previous chapter
        final chapterContent = currentChapterContent.join('\n').trim();
        if (chapterContent.isNotEmpty) {
          final chapter = ChapterModel(
            id: _firestore.collection(AppConstants.chaptersCollection).doc().id,
            bookId: bookId,
            title: currentChapterTitle,
            content: chapterContent,
            chapterNumber: currentChapterNumber,
            createdAt: now,
            updatedAt: now,
            isPublished: true,
            estimatedReadingTimeMinutes: _estimateReadingTime(chapterContent),
          );
          chapters.add(chapter);
          totalPages += _calculatePages(chapterContent);
        }

        // Start new chapter
        currentChapterNumber = chapterNumber ?? (currentChapterNumber + 1);
        currentChapterTitle = chapterTitle ?? 'Chapter $currentChapterNumber';
        currentChapterContent = [];
      } else if (isChapterMarker) {
        // First chapter marker
        currentChapterNumber = chapterNumber ?? 1;
        currentChapterTitle = chapterTitle ?? 'Chapter $currentChapterNumber';
        currentChapterContent = [];
      } else {
        // Add line to current chapter
        currentChapterContent.add(line);
      }
    }

    // Save last chapter
    if (currentChapterContent.isNotEmpty) {
      final chapterContent = currentChapterContent.join('\n').trim();
      if (chapterContent.isNotEmpty) {
        final chapter = ChapterModel(
          id: _firestore.collection(AppConstants.chaptersCollection).doc().id,
          bookId: bookId,
          title: currentChapterTitle,
          content: chapterContent,
          chapterNumber: currentChapterNumber,
          createdAt: now,
          updatedAt: now,
          isPublished: true,
          estimatedReadingTimeMinutes: _estimateReadingTime(chapterContent),
        );
        chapters.add(chapter);
        totalPages += _calculatePages(chapterContent);
      }
    }

    // If no chapters were found, create one chapter with all content
    if (chapters.isEmpty && content.trim().isNotEmpty) {
      final chapter = ChapterModel(
        id: _firestore.collection(AppConstants.chaptersCollection).doc().id,
        bookId: bookId,
        title: 'Chapter 1',
        content: content.trim(),
        chapterNumber: 1,
        createdAt: now,
        updatedAt: now,
        isPublished: true,
        estimatedReadingTimeMinutes: _estimateReadingTime(content),
      );
      chapters.add(chapter);
      totalPages = _calculatePages(content);
    }

    return {
      'chapters': chapters,
      'totalPages': totalPages,
    };
  }

  /// Estimate reading time in minutes (assuming 200 words per minute)
  int _estimateReadingTime(String content) {
    final wordCount = content.split(RegExp(r'\s+')).length;
    return (wordCount / 200).ceil();
  }

  /// Calculate pages (assuming ~250 words per page)
  int _calculatePages(String content) {
    final wordCount = content.split(RegExp(r'\s+')).length;
    return (wordCount / 250).ceil().clamp(1, double.infinity).toInt();
  }
}

