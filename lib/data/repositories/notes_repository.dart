import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import '../../core/constants/app_constants.dart';

class NotesRepository {
  final Box<NoteModel> _notesBox;
  final FirebaseFirestore _firestore;

  NotesRepository({
    required Box<NoteModel> notesBox,
    FirebaseFirestore? firestore,
  })  : _notesBox = notesBox,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Local operations
  Future<void> saveNoteLocally(NoteModel note) async {
    await _notesBox.put(note.id, note);
  }

  Future<void> deleteNoteLocally(String noteId) async {
    await _notesBox.delete(noteId);
  }

  List<NoteModel> getAllLocalNotes() {
    return _notesBox.values.toList();
  }

  NoteModel? getNoteById(String noteId) {
    return _notesBox.get(noteId);
  }

  List<NoteModel> getPendingSyncNotes() {
    return _notesBox.values
        .where((note) => note.syncStatus == AppConstants.syncPending)
        .toList();
  }

  // Cloud operations
  Future<void> syncNoteToCloud(NoteModel note, {bool isGuest = false}) async {
    if (isGuest) {
      // Don't sync to cloud in guest mode
      return;
    }
    
    try {
      await _firestore
          .collection(AppConstants.notesCollection)
          .doc(note.id)
          .set(note.toJson(), SetOptions(merge: true));

      final updatedNote = note.copyWith(syncStatus: AppConstants.syncCompleted);
      await saveNoteLocally(updatedNote);
    } catch (e) {
      final failedNote = note.copyWith(syncStatus: AppConstants.syncFailed);
      await saveNoteLocally(failedNote);
      rethrow;
    }
  }

  Future<void> migrateGuestNotesToUser(String guestUserId, String newUserId) async {
    final guestNotes = _notesBox.values
        .where((note) => note.ownerId == guestUserId)
        .toList();

    for (final note in guestNotes) {
      final migratedNote = note.copyWith(
        ownerId: newUserId,
        syncStatus: AppConstants.syncPending,
      );
      
      await saveNoteLocally(migratedNote);
      await syncNoteToCloud(migratedNote, isGuest: false);
    }
  }

  Future<void> deleteNoteFromCloud(String noteId) async {
    await _firestore.collection(AppConstants.notesCollection).doc(noteId).delete();
  }

  Stream<List<NoteModel>> watchUserNotes(String userId) {
    return _firestore
        .collection(AppConstants.notesCollection)
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromJson(doc.data()))
            .toList());
  }

  Stream<List<NoteModel>> watchSharedNotes(String userId) {
    return _firestore
        .collection(AppConstants.notesCollection)
        .where('collaborators', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromJson(doc.data()))
            .toList());
  }

  Stream<NoteModel?> watchNote(String noteId) {
    return _firestore
        .collection(AppConstants.notesCollection)
        .doc(noteId)
        .snapshots()
        .map((doc) => doc.exists ? NoteModel.fromJson(doc.data()!) : null);
  }

  Future<void> syncAllPendingNotes({bool isGuest = false}) async {
    if (isGuest) return;
    
    final pendingNotes = getPendingSyncNotes();
    for (final note in pendingNotes) {
      await syncNoteToCloud(note, isGuest: isGuest);
    }
  }
}
