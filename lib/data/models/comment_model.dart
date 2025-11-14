import 'package:equatable/equatable.dart';

class CommentModel extends Equatable {
  final String id;
  final String noteId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String text;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? parentCommentId;
  final List<String> mentions;

  const CommentModel({
    required this.id,
    required this.noteId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.text,
    required this.createdAt,
    this.updatedAt,
    this.parentCommentId,
    this.mentions = const [],
  });

  CommentModel copyWith({
    String? id,
    String? noteId,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentCommentId,
    List<String>? mentions,
  }) {
    return CommentModel(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      mentions: mentions ?? this.mentions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noteId': noteId,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'parentCommentId': parentCommentId,
      'mentions': mentions,
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      noteId: json['noteId'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorPhotoUrl: json['authorPhotoUrl'] as String?,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      parentCommentId: json['parentCommentId'] as String?,
      mentions: List<String>.from(json['mentions'] ?? []),
    );
  }

  @override
  List<Object?> get props => [
        id,
        noteId,
        authorId,
        authorName,
        authorPhotoUrl,
        text,
        createdAt,
        updatedAt,
        parentCommentId,
        mentions,
      ];
}
