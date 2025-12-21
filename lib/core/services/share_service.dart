import 'package:share_plus/share_plus.dart';
import '../../core/utils/logger.dart';
import '../../data/models/book_model.dart';

/// Share service for sharing books, quotes, and progress
class ShareService {
  /// Share a book
  Future<void> shareBook(BookModel book) async {
    try {
      final text = '''
📚 ${book.title}

${book.authors.isNotEmpty ? 'By: ${book.authors.join(', ')}\n' : ''}
${book.description != null ? '${book.description!.substring(0, book.description!.length > 200 ? 200 : book.description!.length)}...\n' : ''}
${book.averageRating != null ? '⭐ ${book.averageRating!.toStringAsFixed(1)}/5.0\n' : ''}
Read this amazing book on FusionWave Reader!
      ''';
      
      await Share.share(
        text.trim(),
        subject: book.title,
      );
      
      AppLogger.info('Book shared: ${book.title}');
    } catch (e) {
      AppLogger.error('Share book error', error: e);
      rethrow;
    }
  }
  
  /// Share a quote
  Future<void> shareQuote({
    required String quote,
    String? bookTitle,
    String? author,
  }) async {
    try {
      var text = '"$quote"';
      
      if (bookTitle != null) {
        text += '\n\n— $bookTitle';
      }
      
      if (author != null) {
        text += ' by $author';
      }
      
      text += '\n\nShared from FusionWave Reader';
      
      await Share.share(
        text,
        subject: 'Quote from $bookTitle',
      );
      
      AppLogger.info('Quote shared');
    } catch (e) {
      AppLogger.error('Share quote error', error: e);
      rethrow;
    }
  }
  
  /// Share reading progress
  Future<void> shareReadingProgress({
    required String bookTitle,
    required int currentChapter,
    required int totalChapters,
    required double progress,
  }) async {
    try {
      final progressPercent = (progress * 100).toInt();
      final text = '''
📖 Reading Progress Update

Book: $bookTitle
Chapter: $currentChapter/$totalChapters
Progress: $progressPercent%

Keep reading on FusionWave Reader! 📚
      ''';
      
      await Share.share(
        text.trim(),
        subject: 'Reading Progress: $bookTitle',
      );
      
      AppLogger.info('Reading progress shared');
    } catch (e) {
      AppLogger.error('Share reading progress error', error: e);
      rethrow;
    }
  }
  
  /// Share book with custom message
  Future<void> shareBookWithMessage({
    required BookModel book,
    required String message,
  }) async {
    try {
      final text = '''
$message

📚 ${book.title}
${book.authors.isNotEmpty ? 'By: ${book.authors.join(', ')}\n' : ''}
${book.averageRating != null ? '⭐ ${book.averageRating!.toStringAsFixed(1)}/5.0\n' : ''}
Read on FusionWave Reader!
      ''';
      
      await Share.share(
        text.trim(),
        subject: book.title,
      );
      
      AppLogger.info('Book shared with custom message');
    } catch (e) {
      AppLogger.error('Share book with message error', error: e);
      rethrow;
    }
  }
}

