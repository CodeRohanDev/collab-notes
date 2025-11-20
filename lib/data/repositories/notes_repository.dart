import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note_model.dart';
import '../../core/constants/app_constants.dart';

class NotesRepository {
  final Box<NoteModel> _notesBox;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotesRepository({
    required Box<NoteModel> notesBox,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _notesBox = notesBox,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Check if user is authenticated (not guest)
  bool get isAuthenticated => _auth.currentUser != null;

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

  // Cloud operations - only if authenticated and sync is enabled for the note
  Future<void> syncNoteToCloud(NoteModel note, {bool isGuest = false}) async {
    // Don't sync if user is not authenticated or note sync is disabled
    if (isGuest || !isAuthenticated || !note.isSyncEnabled) {
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

  // Enable sync for a specific note
  Future<void> enableSyncForNote(String noteId) async {
    if (!isAuthenticated) {
      throw Exception('Must be logged in to enable sync');
    }
    
    final note = getNoteById(noteId);
    if (note == null) return;

    final updatedNote = note.copyWith(
      isSyncEnabled: true,
      syncStatus: AppConstants.syncPending,
    );
    
    await saveNoteLocally(updatedNote);
    await syncNoteToCloud(updatedNote);
  }

  // Disable sync for a specific note (keeps local copy)
  Future<void> disableSyncForNote(String noteId) async {
    final note = getNoteById(noteId);
    if (note == null) return;

    final updatedNote = note.copyWith(
      isSyncEnabled: false,
      syncStatus: AppConstants.syncCompleted,
    );
    
    await saveNoteLocally(updatedNote);
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

  // Delete note from cloud only (keeps local copy)
  Future<void> deleteNoteFromCloud(String noteId) async {
    if (!isAuthenticated) {
      throw Exception('Must be logged in to delete from cloud');
    }
    await _firestore.collection(AppConstants.notesCollection).doc(noteId).delete();
  }

  // Delete note locally and optionally from cloud
  Future<void> deleteNote(String noteId, {bool deleteFromCloud = false}) async {
    final note = getNoteById(noteId);
    
    // Delete from cloud if requested and user is authenticated
    if (deleteFromCloud && isAuthenticated && note?.isSyncEnabled == true) {
      try {
        await deleteNoteFromCloud(noteId);
      } catch (e) {
        // Continue with local deletion even if cloud deletion fails
      }
    }
    
    // Always delete locally
    await deleteNoteLocally(noteId);
  }

  Stream<List<NoteModel>> watchUserNotes(String userId) {
    if (!isAuthenticated) {
      // Return empty stream if not authenticated
      return Stream.value([]);
    }
    
    return _firestore
        .collection(AppConstants.notesCollection)
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromJson(doc.data()))
            .toList());
  }

  Stream<List<NoteModel>> watchSharedNotes(String userId) {
    if (!isAuthenticated) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(AppConstants.notesCollection)
        .where('collaborators', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromJson(doc.data()))
            .toList());
  }

  Stream<NoteModel?> watchNote(String noteId) {
    if (!isAuthenticated) {
      return Stream.value(null);
    }
    
    return _firestore
        .collection(AppConstants.notesCollection)
        .doc(noteId)
        .snapshots()
        .map((doc) => doc.exists ? NoteModel.fromJson(doc.data()!) : null);
  }

  Future<void> syncAllPendingNotes({bool isGuest = false}) async {
    if (isGuest || !isAuthenticated) return;
    
    // Only sync notes that have sync enabled
    final pendingNotes = getPendingSyncNotes()
        .where((note) => note.isSyncEnabled)
        .toList();
    
    for (final note in pendingNotes) {
      await syncNoteToCloud(note, isGuest: isGuest);
    }
  }

  // Collaboration methods - require authentication
  Future<void> addCollaborator(String noteId, String email) async {
    if (!isAuthenticated) {
      throw Exception('Must be logged in to add collaborators');
    }
    
    final note = getNoteById(noteId);
    if (note == null) return;

    final updatedCollaborators = [...note.collaborators];
    if (!updatedCollaborators.contains(email)) {
      updatedCollaborators.add(email);
    }

    final updatedNote = note.copyWith(
      collaborators: updatedCollaborators,
      syncStatus: AppConstants.syncPending,
      isSyncEnabled: true, // Enable sync when adding collaborators
    );

    await saveNoteLocally(updatedNote);
    await syncNoteToCloud(updatedNote);
  }

  Future<void> removeCollaborator(String noteId, String email) async {
    if (!isAuthenticated) {
      throw Exception('Must be logged in to remove collaborators');
    }
    
    final note = getNoteById(noteId);
    if (note == null) return;

    final updatedCollaborators = note.collaborators.where((e) => e != email).toList();

    final updatedNote = note.copyWith(
      collaborators: updatedCollaborators,
      syncStatus: AppConstants.syncPending,
    );

    await saveNoteLocally(updatedNote);
    await syncNoteToCloud(updatedNote);
  }

  // Real-time sync - only when authenticated
  Stream<List<NoteModel>> watchAllUserNotes(String userId) {
    if (!isAuthenticated) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(AppConstants.notesCollection)
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final notes = snapshot.docs
          .map((doc) => NoteModel.fromJson(doc.data()))
          .toList();
      
      // Update local storage with cloud data
      for (final note in notes) {
        await saveNoteLocally(note);
      }
      
      return notes;
    });
  }

  Stream<List<NoteModel>> watchAllAccessibleNotes(String userId) {
    if (!isAuthenticated) {
      return Stream.value([]);
    }
    
    // Combine owned and shared notes
    return _firestore
        .collection(AppConstants.notesCollection)
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .asyncMap((ownedSnapshot) async {
      final ownedNotes = ownedSnapshot.docs
          .map((doc) => NoteModel.fromJson(doc.data()))
          .toList();

      // Get shared notes
      final sharedSnapshot = await _firestore
          .collection(AppConstants.notesCollection)
          .where('collaborators', arrayContains: userId)
          .get();

      final sharedNotes = sharedSnapshot.docs
          .map((doc) => NoteModel.fromJson(doc.data()))
          .toList();

      final allNotes = [...ownedNotes, ...sharedNotes];
      
      // Update local storage
      for (final note in allNotes) {
        await saveNoteLocally(note);
      }
      
      return allNotes;
    });
  }

  // Get all local notes (works offline)
  List<NoteModel> getLocalNotesOnly() {
    return _notesBox.values.toList();
  }

  // Get synced notes count
  int getSyncedNotesCount() {
    return _notesBox.values.where((note) => note.isSyncEnabled).length;
  }

  // Get local-only notes count
  int getLocalOnlyNotesCount() {
    return _notesBox.values.where((note) => !note.isSyncEnabled).length;
  }

  // Fetch a shared note by ID (for deep linking)
  Future<NoteModel?> fetchSharedNote(String noteId) async {
    if (!isAuthenticated) {
      throw Exception('Must be logged in to access shared notes');
    }

    try {
      final user = _auth.currentUser!;
      
      // Fetch from Firestore
      final doc = await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .get();
      
      if (!doc.exists) {
        return null;
      }

      final note = NoteModel.fromJson(doc.data()!);

      // Check if user has access (owner or collaborator)
      if (note.ownerId != user.uid && !note.collaborators.contains(user.email)) {
        throw Exception('You do not have access to this note');
      }

      // Save to local cache
      await saveNoteLocally(note);

      return note;
    } catch (e) {
      throw Exception('Failed to fetch shared note: $e');
    }
  }

  // Accept collaboration invitation
  Future<NoteModel> acceptCollaborationInvite(String noteId) async {
    if (!isAuthenticated) {
      throw Exception('Must be logged in to accept invitations');
    }

    try {
      final user = _auth.currentUser!;
      
      // Fetch the note first
      final doc = await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Note not found');
      }

      final note = NoteModel.fromJson(doc.data()!);

      // Check if already a collaborator
      if (note.collaborators.contains(user.email)) {
        // Already a collaborator, just fetch and cache
        await saveNoteLocally(note);
        return note;
      }

      // Add current user as collaborator
      await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .update({
        'collaborators': FieldValue.arrayUnion([user.email]),
      });

      // Update local note
      final updatedNote = note.copyWith(
        collaborators: [...note.collaborators, user.email!],
      );
      
      await saveNoteLocally(updatedNote);
      
      return updatedNote;
    } catch (e) {
      throw Exception('Failed to accept collaboration invite: $e');
    }
  }
}
