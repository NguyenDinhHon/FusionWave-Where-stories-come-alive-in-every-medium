import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firebase_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/note_model.dart';
import '../../core/utils/logger.dart';

/// Note repository
class NoteRepository {
  final FirebaseService _firebaseService = FirebaseService();
  
  FirebaseFirestore get _firestore => _firebaseService.firestore;
  FirebaseAuth get _auth => _firebaseService.auth;
  
  String? get _currentUserId => _auth.currentUser?.uid;
  
  // Add note
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
    try {
      if (_currentUserId == null) {
        throw Exception('User must be logged in to add note');
      }
      
      final noteModel = NoteModel(
        id: '', // Will be set by Firestore
        userId: _currentUserId!,
        bookId: bookId,
        chapterId: chapterId,
        chapterNumber: chapterNumber,
        highlightedText: highlightedText,
        note: note,
        startPosition: startPosition,
        endPosition: endPosition,
        color: color ?? '#FFFF00', // Default yellow
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final docRef = await _firestore
          .collection(AppConstants.notesCollection)
          .add(noteModel.toFirestore());
      
      AppLogger.info('Note added: ${docRef.id}');
      return noteModel.copyWith(id: docRef.id);
    } catch (e) {
      AppLogger.error('Add note error', error: e);
      rethrow;
    }
  }
  
  // Get notes by book ID
  Stream<List<NoteModel>> getNotesByBookId(String bookId) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(AppConstants.notesCollection)
        .where('userId', isEqualTo: _currentUserId)
        .where('bookId', isEqualTo: bookId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromFirestore(doc))
            .toList());
  }
  
  // Get notes by chapter ID
  Stream<List<NoteModel>> getNotesByChapterId(String chapterId) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(AppConstants.notesCollection)
        .where('userId', isEqualTo: _currentUserId)
        .where('chapterId', isEqualTo: chapterId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromFirestore(doc))
            .toList());
  }
  
  // Get all notes for current user
  Stream<List<NoteModel>> getUserNotes() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(AppConstants.notesCollection)
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromFirestore(doc))
            .toList());
  }
  
  // Get note by ID
  Future<NoteModel?> getNoteById(String noteId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .get();
      
      if (!doc.exists) {
        return null;
      }
      
      return NoteModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.error('Get note by ID error', error: e);
      rethrow;
    }
  }
  
  // Update note
  Future<void> updateNote(String noteId, {
    String? note,
    String? color,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (note != null) updates['note'] = note;
      if (color != null) updates['color'] = color;
      
      await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .update(updates);
      
      AppLogger.info('Note updated: $noteId');
    } catch (e) {
      AppLogger.error('Update note error', error: e);
      rethrow;
    }
  }
  
  // Delete note
  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .delete();
      
      AppLogger.info('Note deleted: $noteId');
    } catch (e) {
      AppLogger.error('Delete note error', error: e);
      rethrow;
    }
  }
  
  // Export notes as text
  Future<String> exportNotesAsText(String bookId) async {
    try {
      final notes = await getNotesByBookId(bookId).first;
      if (notes.isEmpty) return '';
      
      final buffer = StringBuffer();
      buffer.writeln('Notes Export');
      buffer.writeln('=' * 50);
      buffer.writeln();
      
      for (final note in notes) {
        buffer.writeln('Chapter ${note.chapterNumber}');
        buffer.writeln('-' * 30);
        buffer.writeln('Highlighted: ${note.highlightedText}');
        buffer.writeln('Note: ${note.note}');
        buffer.writeln('Date: ${note.createdAt}');
        buffer.writeln();
      }
      
      return buffer.toString();
    } catch (e) {
      AppLogger.error('Export notes error', error: e);
      rethrow;
    }
  }
}

