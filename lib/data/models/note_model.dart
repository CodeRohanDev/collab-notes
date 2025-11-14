import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String ownerId;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final List<String> collaborators;

  @HiveField(7)
  final List<String> tags;

  @HiveField(8)
  final bool isPrivate;

  @HiveField(9)
  final String? workspaceId;

  @HiveField(10)
  final String syncStatus;

  @HiveField(11)
  final bool isPinned;

  @HiveField(12)
  final bool isArchived;

  @HiveField(13)
  final String? color;

  @HiveField(14)
  final List<String> attachments;

  @HiveField(15)
  final String? reminder;

  @HiveField(16)
  final bool isFavorite;

  @HiveField(17)
  final String noteType; // 'note', 'todo', 'checklist', 'drawing'

  @HiveField(18)
  final List<Map<String, dynamic>> checklistItems;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.collaborators = const [],
    this.tags = const [],
    this.isPrivate = false,
    this.workspaceId,
    this.syncStatus = 'completed',
    this.isPinned = false,
    this.isArchived = false,
    this.color,
    this.attachments = const [],
    this.reminder,
    this.isFavorite = false,
    this.noteType = 'note',
    this.checklistItems = const [],
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? collaborators,
    List<String>? tags,
    bool? isPrivate,
    String? workspaceId,
    String? syncStatus,
    bool? isPinned,
    bool? isArchived,
    String? color,
    List<String>? attachments,
    String? reminder,
    bool? isFavorite,
    String? noteType,
    List<Map<String, dynamic>>? checklistItems,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      collaborators: collaborators ?? this.collaborators,
      tags: tags ?? this.tags,
      isPrivate: isPrivate ?? this.isPrivate,
      workspaceId: workspaceId ?? this.workspaceId,
      syncStatus: syncStatus ?? this.syncStatus,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      color: color ?? this.color,
      attachments: attachments ?? this.attachments,
      reminder: reminder ?? this.reminder,
      isFavorite: isFavorite ?? this.isFavorite,
      noteType: noteType ?? this.noteType,
      checklistItems: checklistItems ?? this.checklistItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'collaborators': collaborators,
      'tags': tags,
      'isPrivate': isPrivate,
      'workspaceId': workspaceId,
      'isPinned': isPinned,
      'isArchived': isArchived,
      'color': color,
      'attachments': attachments,
      'reminder': reminder,
      'isFavorite': isFavorite,
      'noteType': noteType,
      'checklistItems': checklistItems,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      collaborators: List<String>.from(json['collaborators'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      isPrivate: json['isPrivate'] as bool? ?? false,
      workspaceId: json['workspaceId'] as String?,
      syncStatus: 'completed',
      isPinned: json['isPinned'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      color: json['color'] as String?,
      attachments: List<String>.from(json['attachments'] ?? []),
      reminder: json['reminder'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      noteType: json['noteType'] as String? ?? 'note',
      checklistItems: List<Map<String, dynamic>>.from(json['checklistItems'] ?? []),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        ownerId,
        createdAt,
        updatedAt,
        collaborators,
        tags,
        isPrivate,
        workspaceId,
        syncStatus,
        isPinned,
        isArchived,
        color,
        attachments,
        reminder,
        isFavorite,
        noteType,
        checklistItems,
      ];
}
