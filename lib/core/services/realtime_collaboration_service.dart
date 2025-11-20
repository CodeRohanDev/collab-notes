import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/presence_model.dart';

/// Service for handling real-time collaboration features
class RealtimeCollaborationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  // Streams
  StreamSubscription? _noteSubscription;
  StreamSubscription? _presenceSubscription;
  Timer? _presenceTimer;
  
  // Current state
  String? _currentNoteId;
  String? _currentUserId;

  RealtimeCollaborationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Start listening to note changes
  Stream<Map<String, dynamic>?> watchNoteChanges(String noteId) {
    _currentNoteId = noteId;
    _currentUserId = _auth.currentUser?.uid;

    return _firestore
        .collection('notes')
        .doc(noteId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return snapshot.data();
    });
  }

  /// Start listening to presence updates
  Stream<List<PresenceModel>> watchPresence(String noteId) {
    return _firestore
        .collection('notes')
        .doc(noteId)
        .collection('presence')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PresenceModel.fromJson(doc.data()))
          .where((presence) => presence.userId != _currentUserId)
          .where((presence) {
            // Only show users active in last 30 seconds
            final diff = DateTime.now().difference(presence.lastSeen);
            return diff.inSeconds < 30;
          })
          .toList();
    });
  }

  /// Update user's presence
  Future<void> updatePresence({
    required String noteId,
    int? cursorPosition,
    int? selectionStart,
    int? selectionEnd,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final presence = PresenceModel(
      userId: user.uid,
      userName: user.displayName ?? 'Anonymous',
      userEmail: user.email ?? '',
      userPhotoUrl: user.photoURL,
      lastSeen: DateTime.now(),
      isActive: true,
      cursorPosition: cursorPosition,
      selectionStart: selectionStart,
      selectionEnd: selectionEnd,
    );

    await _firestore
        .collection('notes')
        .doc(noteId)
        .collection('presence')
        .doc(user.uid)
        .set(presence.toJson(), SetOptions(merge: true));
  }

  /// Start presence heartbeat
  void startPresenceHeartbeat(String noteId) {
    _presenceTimer?.cancel();
    
    // Update presence every 5 seconds
    _presenceTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      updatePresence(noteId: noteId);
    });

    // Initial update
    updatePresence(noteId: noteId);
  }

  /// Stop presence heartbeat
  Future<void> stopPresenceHeartbeat(String noteId) async {
    _presenceTimer?.cancel();
    _presenceTimer = null;

    final user = _auth.currentUser;
    if (user == null) return;

    // Mark as inactive
    await _firestore
        .collection('notes')
        .doc(noteId)
        .collection('presence')
        .doc(user.uid)
        .update({
      'isActive': false,
      'lastSeen': DateTime.now().toIso8601String(),
    });
  }

  /// Update note content (for real-time sync)
  Future<void> updateNoteContent({
    required String noteId,
    required String content,
    required String title,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('notes').doc(noteId).update({
      'content': content,
      'title': title,
      'updatedAt': DateTime.now().toIso8601String(),
      'lastEditedBy': user.uid,
    });
  }

  /// Clean up old presence records
  Future<void> cleanupPresence(String noteId) async {
    final snapshot = await _firestore
        .collection('notes')
        .doc(noteId)
        .collection('presence')
        .get();

    final now = DateTime.now();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final lastSeen = DateTime.parse(data['lastSeen'] as String);
      final diff = now.difference(lastSeen);

      // Delete presence records older than 1 minute
      if (diff.inMinutes > 1) {
        batch.delete(doc.reference);
      }
    }

    await batch.commit();
  }

  /// Dispose and cleanup
  void dispose() {
    _noteSubscription?.cancel();
    _presenceSubscription?.cancel();
    _presenceTimer?.cancel();
    
    if (_currentNoteId != null) {
      stopPresenceHeartbeat(_currentNoteId!);
    }
  }
}
