import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/logger.dart';

/// Offline service for downloading and caching books
class OfflineService {
  static const String _keyOfflineBooks = 'offline_books';
  static const String _keyOfflineChapters = 'offline_chapters';
  
  SharedPreferences? _prefs;
  Directory? _offlineDirectory;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final appDir = await getApplicationDocumentsDirectory();
    _offlineDirectory = Directory('${appDir.path}/offline_content');
    if (!await _offlineDirectory!.exists()) {
      await _offlineDirectory!.create(recursive: true);
    }
    AppLogger.info('Offline service initialized');
  }
  
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('OfflineService not initialized. Call init() first.');
    }
    return _prefs!;
  }
  
  Directory get offlineDir {
    if (_offlineDirectory == null) {
      throw Exception('OfflineService not initialized. Call init() first.');
    }
    return _offlineDirectory!;
  }
  
  // Check if book is downloaded
  bool isBookDownloaded(String bookId) {
    final offlineBooks = prefs.getStringList(_keyOfflineBooks) ?? [];
    return offlineBooks.contains(bookId);
  }
  
  // Get downloaded books
  List<String> getDownloadedBooks() {
    return prefs.getStringList(_keyOfflineBooks) ?? [];
  }
  
  // Download book (mark as downloaded)
  Future<void> downloadBook(String bookId) async {
    final offlineBooks = prefs.getStringList(_keyOfflineBooks) ?? [];
    if (!offlineBooks.contains(bookId)) {
      offlineBooks.add(bookId);
      await prefs.setStringList(_keyOfflineBooks, offlineBooks);
      AppLogger.info('Book downloaded: $bookId');
    }
  }
  
  // Remove downloaded book
  Future<void> removeDownloadedBook(String bookId) async {
    final offlineBooks = prefs.getStringList(_keyOfflineBooks) ?? [];
    offlineBooks.remove(bookId);
    await prefs.setStringList(_keyOfflineBooks, offlineBooks);
    
    // Remove cached files
    try {
      final bookDir = Directory('${offlineDir.path}/$bookId');
      if (await bookDir.exists()) {
        await bookDir.delete(recursive: true);
      }
    } catch (e) {
      AppLogger.error('Error removing book files', error: e);
    }
    
    AppLogger.info('Book removed from offline: $bookId');
  }
  
  // Cache chapter content
  Future<void> cacheChapter({
    required String bookId,
    required String chapterId,
    required String content,
  }) async {
    try {
      final bookDir = Directory('${offlineDir.path}/$bookId');
      if (!await bookDir.exists()) {
        await bookDir.create(recursive: true);
      }
      
      final chapterFile = File('${bookDir.path}/$chapterId.txt');
      await chapterFile.writeAsString(content);
      
      AppLogger.info('Chapter cached: $bookId/$chapterId');
    } catch (e) {
      AppLogger.error('Cache chapter error', error: e);
      rethrow;
    }
  }
  
  // Get cached chapter content
  Future<String?> getCachedChapter({
    required String bookId,
    required String chapterId,
  }) async {
    try {
      final chapterFile = File('${offlineDir.path}/$bookId/$chapterId.txt');
      if (await chapterFile.exists()) {
        return await chapterFile.readAsString();
      }
      return null;
    } catch (e) {
      AppLogger.error('Get cached chapter error', error: e);
      return null;
    }
  }
  
  // Cache book cover
  Future<void> cacheBookCover({
    required String bookId,
    required String imageUrl,
  }) async {
    HttpClient client = HttpClient();
    try {
      final bookDir = Directory('${offlineDir.path}/$bookId');
      if (!await bookDir.exists()) {
        await bookDir.create(recursive: true);
      }

      final uri = Uri.parse(imageUrl);
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode != 200) {
        AppLogger.error('Failed to download cover: HTTP ${response.statusCode}');
        return;
      }

      // Collect bytes
      final bytes = <int>[];
      await for (var chunk in response) {
        bytes.addAll(chunk);
      }

      // Determine extension from content-type
      String ext = 'jpg';
      final contentType = response.headers.contentType?.mimeType;
      if (contentType != null) {
        if (contentType.contains('png')) {
          ext = 'png';
        } else if (contentType.contains('webp')) ext = 'webp';
        else if (contentType.contains('jpeg') || contentType.contains('jpg')) ext = 'jpg';
      }

      final file = File('${bookDir.path}/cover.$ext');
      await file.writeAsBytes(Uint8List.fromList(bytes));

      AppLogger.info('Book cover cached: $bookId -> ${file.path}');
    } catch (e) {
      AppLogger.error('Cache book cover error', error: e);
    } finally {
      try {
        client.close(force: true);
      } catch (_) {}
    }
  }
  
  // Get offline storage size
  Future<int> getOfflineStorageSize() async {
    try {
      int totalSize = 0;
      if (await offlineDir.exists()) {
        await for (var entity in offlineDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
      return totalSize;
    } catch (e) {
      AppLogger.error('Get offline storage size error', error: e);
      return 0;
    }
  }
  
  // Clear all offline content
  Future<void> clearAllOfflineContent() async {
    try {
      if (await offlineDir.exists()) {
        await offlineDir.delete(recursive: true);
        await offlineDir.create(recursive: true);
      }
      await prefs.remove(_keyOfflineBooks);
      await prefs.remove(_keyOfflineChapters);
      AppLogger.info('All offline content cleared');
    } catch (e) {
      AppLogger.error('Clear offline content error', error: e);
      rethrow;
    }
  }
}

