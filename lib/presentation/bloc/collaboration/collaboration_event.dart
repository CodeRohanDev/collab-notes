part of 'collaboration_bloc.dart';

abstract class CollaborationEvent extends Equatable {
  const CollaborationEvent();

  @override
  List<Object?> get props => [];
}

/// Start watching a note for real-time changes
class CollaborationStartWatching extends CollaborationEvent {
  final String noteId;

  const CollaborationStartWatching({required this.noteId});

  @override
  List<Object> get props => [noteId];
}

/// Stop watching the current note
class CollaborationStopWatching extends CollaborationEvent {}

/// Note content changed remotely
class CollaborationNoteUpdated extends CollaborationEvent {
  final Map<String, dynamic> noteData;

  const CollaborationNoteUpdated({required this.noteData});

  @override
  List<Object> get props => [noteData];
}

/// Presence list updated
class CollaborationPresenceUpdated extends CollaborationEvent {
  final List<PresenceModel> activeUsers;

  const CollaborationPresenceUpdated({required this.activeUsers});

  @override
  List<Object> get props => [activeUsers];
}

/// Update local cursor position
class CollaborationUpdateCursor extends CollaborationEvent {
  final int? cursorPosition;
  final int? selectionStart;
  final int? selectionEnd;

  const CollaborationUpdateCursor({
    this.cursorPosition,
    this.selectionStart,
    this.selectionEnd,
  });

  @override
  List<Object?> get props => [cursorPosition, selectionStart, selectionEnd];
}

/// Send local changes to server
class CollaborationSendChanges extends CollaborationEvent {
  final String content;
  final String title;

  const CollaborationSendChanges({
    required this.content,
    required this.title,
  });

  @override
  List<Object> get props => [content, title];
}
