import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/note_repository.dart';
import '../../../../data/models/note_model.dart';

/// Note repository provider
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

/// Notes by book ID provider
final notesByBookIdProvider = StreamProvider.family<List<NoteModel>, String>((ref, bookId) {
  final repository = ref.watch(noteRepositoryProvider);
  return repository.getNotesByBookId(bookId);
});

/// Notes by chapter ID provider
final notesByChapterIdProvider = StreamProvider.family<List<NoteModel>, String>((ref, chapterId) {
  final repository = ref.watch(noteRepositoryProvider);
  return repository.getNotesByChapterId(chapterId);
});

/// User notes provider
final userNotesProvider = StreamProvider<List<NoteModel>>((ref) {
  final repository = ref.watch(noteRepositoryProvider);
  return repository.getUserNotes();
});

/// Note controller provider
final noteControllerProvider = Provider<NoteController>((ref) {
  return NoteController(ref.read(noteRepositoryProvider));
});

class NoteController {
  final NoteRepository _repository;
  
  NoteController(this._repository);
  
  Future<NoteModel> addNote({
    required String bookId,
    required String chapterId,
    required int chapterNumber,
    required String highlightedText,
    required String note,
    int? startPosition,
    int? endPosition,
    String? color,
  }) async {
    return await _repository.addNote(
      bookId: bookId,
      chapterId: chapterId,
      chapterNumber: chapterNumber,
      highlightedText: highlightedText,
      note: note,
      startPosition: startPosition,
      endPosition: endPosition,
      color: color,
    );
  }
  
  Future<void> deleteNote(String noteId) async {
    await _repository.deleteNote(noteId);
  }
  
  Future<void> updateNote(String noteId, {
    String? note,
    String? color,
  }) async {
    await _repository.updateNote(noteId, note: note, color: color);
  }
  
  Future<String> exportNotesAsText(String bookId) async {
    return await _repository.exportNotesAsText(bookId);
  }
}

