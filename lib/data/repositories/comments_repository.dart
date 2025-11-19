import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentsRepository {
  final FirebaseFirestore _firestore;

  CommentsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Add comment to a note
  Future<void> addComment(CommentModel comment) async {
    await _firestore
        .collection('comments')
        .doc(comment.id)
        .set(comment.toJson());
  }

  // Get comments for a note
  Stream<List<CommentModel>> watchNoteComments(String noteId) {
    return _firestore
        .collection('comments')
        .where('noteId', isEqualTo: noteId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromJson(doc.data()))
            .toList());
  }

  // Delete comment
  Future<void> deleteComment(String commentId) async {
    await _firestore.collection('comments').doc(commentId).delete();
  }

  // Update comment
  Future<void> updateComment(String commentId, String newText) async {
    await _firestore.collection('comments').doc(commentId).update({
      'text': newText,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Add reply to comment
  Future<void> addReply(String parentCommentId, CommentModel reply) async {
    await _firestore
        .collection('comments')
        .doc(reply.id)
        .set(reply.toJson());
  }

  // Get replies for a comment
  Stream<List<CommentModel>> watchCommentReplies(String parentCommentId) {
    return _firestore
        .collection('comments')
        .where('parentCommentId', isEqualTo: parentCommentId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromJson(doc.data()))
            .toList());
  }
}
