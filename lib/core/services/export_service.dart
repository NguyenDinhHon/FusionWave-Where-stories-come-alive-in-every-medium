import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import '../../data/models/book_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/rating_model.dart';
import '../../data/models/bookmark_model.dart';
import '../../data/models/library_item_model.dart';
import '../../data/models/collection_model.dart';

/// Service để export data ra CSV/JSON
class ExportService {
  /// Export books to CSV
  Future<void> exportBooksToCSV(List<BookModel> books) async {
    try {
      if (books.isEmpty) {
        throw Exception('Không có dữ liệu để export');
      }

      // CSV Header
      final csvBuffer = StringBuffer();
      csvBuffer.writeln(
        'ID,Title,Subtitle,Authors,Categories,Tags,Rating,Views,Chapters,Pages,Published,Created At',
      );

      // CSV Data
      for (final book in books) {
        csvBuffer.writeln(
          [
            book.id,
            _escapeCsvField(book.title),
            _escapeCsvField(book.subtitle ?? ''),
            _escapeCsvField(book.authors.join('; ')),
            _escapeCsvField(book.categories.join('; ')),
            _escapeCsvField(book.tags.join('; ')),
            book.averageRating?.toString() ?? '',
            book.totalReads.toString(),
            book.totalChapters.toString(),
            book.totalPages.toString(),
            book.isPublished ? 'Yes' : 'No',
            book.createdAt.toIso8601String(),
          ].join(','),
        );
      }

      // Share CSV content
      await SharePlus.instance.share(
        ShareParams(text: csvBuffer.toString()),
      );
    } catch (e) {
      throw Exception('Lỗi khi export CSV: $e');
    }
  }

  /// Export books to JSON
  Future<void> exportBooksToJSON(List<BookModel> books) async {
    try {
      if (books.isEmpty) {
        throw Exception('Không có dữ liệu để export');
      }

      // Convert to JSON
      final jsonData = {
        'exportDate': DateTime.now().toIso8601String(),
        'totalBooks': books.length,
        'books': books.map((book) => {
          'id': book.id,
          'title': book.title,
          'subtitle': book.subtitle,
          'authors': book.authors,
          'description': book.description,
          'categories': book.categories,
          'tags': book.tags,
          'coverImageUrl': book.coverImageUrl,
          'audioUrl': book.audioUrl,
          'videoUrl': book.videoUrl,
          'totalPages': book.totalPages,
          'totalChapters': book.totalChapters,
          'averageRating': book.averageRating,
          'totalRatings': book.totalRatings,
          'totalReads': book.totalReads,
          'isPublished': book.isPublished,
          'language': book.language,
          'editorId': book.editorId,
          'createdAt': book.createdAt.toIso8601String(),
          'updatedAt': book.updatedAt.toIso8601String(),
          'estimatedReadingTimeMinutes': book.estimatedReadingTimeMinutes,
        }).toList(),
      };

      // Format JSON with indentation
      const encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(jsonData);

      // Share JSON content
      await SharePlus.instance.share(
        ShareParams(text: jsonString),
      );
    } catch (e) {
      throw Exception('Lỗi khi export JSON: $e');
    }
  }

  /// Export users to CSV
  Future<void> exportUsersToCSV(List<UserModel> users) async {
    try {
      if (users.isEmpty) {
        throw Exception('Không có dữ liệu để export');
      }

      final csvBuffer = StringBuffer();
      csvBuffer.writeln('ID,Email,Display Name,Role,Created At,Last Login,Reading Streak');

      for (final user in users) {
        csvBuffer.writeln([
          user.id,
          _escapeCsvField(user.email),
          _escapeCsvField(user.displayName ?? ''),
          user.role,
          user.createdAt.toIso8601String(),
          user.lastLoginAt?.toIso8601String() ?? '',
          user.readingStreak.toString(),
        ].join(','));
      }

      await SharePlus.instance.share(
        ShareParams(text: csvBuffer.toString()),
      );
    } catch (e) {
      throw Exception('Lỗi khi export users CSV: $e');
    }
  }

  /// Export comments to CSV
  Future<void> exportCommentsToCSV(List<CommentModel> comments) async {
    try {
      if (comments.isEmpty) {
        throw Exception('Không có dữ liệu để export');
      }

      final csvBuffer = StringBuffer();
      csvBuffer.writeln('ID,User ID,Book ID,Chapter ID,Content,Parent Comment ID,Likes,Created At,Updated At');

      for (final comment in comments) {
        csvBuffer.writeln([
          comment.id,
          comment.userId,
          comment.bookId,
          comment.chapterId ?? '',
          _escapeCsvField(comment.content),
          comment.parentCommentId ?? '',
          comment.likes.toString(),
          comment.createdAt.toIso8601String(),
          comment.updatedAt?.toIso8601String() ?? '',
        ].join(','));
      }

      await SharePlus.instance.share(
        ShareParams(text: csvBuffer.toString()),
      );
    } catch (e) {
      throw Exception('Lỗi khi export comments CSV: $e');
    }
  }

  /// Export ratings to CSV
  Future<void> exportRatingsToCSV(List<RatingModel> ratings) async {
    try {
      if (ratings.isEmpty) {
        throw Exception('Không có dữ liệu để export');
      }

      final csvBuffer = StringBuffer();
      csvBuffer.writeln('ID,User ID,Book ID,Rating,Review,Created At,Updated At');

      for (final rating in ratings) {
        csvBuffer.writeln([
          rating.id,
          rating.userId,
          rating.bookId,
          rating.rating.toString(),
          _escapeCsvField(rating.review ?? ''),
          rating.createdAt.toIso8601String(),
          rating.updatedAt?.toIso8601String() ?? '',
        ].join(','));
      }

      await SharePlus.instance.share(
        ShareParams(text: csvBuffer.toString()),
      );
    } catch (e) {
      throw Exception('Lỗi khi export ratings CSV: $e');
    }
  }

  /// Export bookmarks to CSV
  Future<void> exportBookmarksToCSV(List<BookmarkModel> bookmarks) async {
    try {
      if (bookmarks.isEmpty) {
        throw Exception('Không có dữ liệu để export');
      }

      final csvBuffer = StringBuffer();
      csvBuffer.writeln('ID,User ID,Book ID,Chapter ID,Chapter Number,Page Number,Note,Highlighted Text,Created At');

      for (final bookmark in bookmarks) {
        csvBuffer.writeln([
          bookmark.id,
          bookmark.userId,
          bookmark.bookId,
          bookmark.chapterId,
          bookmark.chapterNumber.toString(),
          bookmark.pageNumber?.toString() ?? '',
          _escapeCsvField(bookmark.note ?? ''),
          _escapeCsvField(bookmark.highlightedText ?? ''),
          bookmark.createdAt.toIso8601String(),
        ].join(','));
      }

      await SharePlus.instance.share(
        ShareParams(text: csvBuffer.toString()),
      );
    } catch (e) {
      throw Exception('Lỗi khi export bookmarks CSV: $e');
    }
  }

  /// Export library items to CSV
  Future<void> exportLibraryItemsToCSV(List<LibraryItemModel> items) async {
    try {
      if (items.isEmpty) {
        throw Exception('Không có dữ liệu để export');
      }

      final csvBuffer = StringBuffer();
      csvBuffer.writeln('ID,User ID,Book ID,Status,Current Page,Current Chapter,Progress,Reading Time (min),Last Read At,Added At');

      for (final item in items) {
        csvBuffer.writeln([
          item.id,
          item.userId,
          item.bookId,
          item.status,
          item.currentPage.toString(),
          item.currentChapter.toString(),
          item.progress.toStringAsFixed(2),
          item.totalReadingTimeMinutes.toString(),
          item.lastReadAt?.toIso8601String() ?? '',
          item.addedAt.toIso8601String(),
        ].join(','));
      }

      await SharePlus.instance.share(
        ShareParams(text: csvBuffer.toString()),
      );
    } catch (e) {
      throw Exception('Lỗi khi export library items CSV: $e');
    }
  }

  /// Export collections to CSV
  Future<void> exportCollectionsToCSV(List<CollectionModel> collections) async {
    try {
      if (collections.isEmpty) {
        throw Exception('Không có dữ liệu để export');
      }

      final csvBuffer = StringBuffer();
      csvBuffer.writeln('ID,User ID,Name,Description,Book Count,Is Public,Created At,Updated At');

      for (final collection in collections) {
        csvBuffer.writeln([
          collection.id,
          collection.userId,
          _escapeCsvField(collection.name),
          _escapeCsvField(collection.description ?? ''),
          collection.bookIds.length.toString(),
          collection.isPublic ? 'Yes' : 'No',
          collection.createdAt.toIso8601String(),
          collection.updatedAt.toIso8601String(),
        ].join(','));
      }

      await SharePlus.instance.share(
        ShareParams(text: csvBuffer.toString()),
      );
    } catch (e) {
      throw Exception('Lỗi khi export collections CSV: $e');
    }
  }

  /// Escape CSV field (handle commas, quotes, newlines)
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
