part of 'notes_bloc.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

class NotesLoadRequested extends NotesEvent {}

class NotesCreateRequested extends NotesEvent {
  final String title;
  final String content;
  final List<Map<String, dynamic>>? checklistItems;

  const NotesCreateRequested({
    required this.title,
    required this.content,
    this.checklistItems,
  });

  @override
  List<Object> get props => [title, content, checklistItems ?? []];
}

class NotesUpdateRequested extends NotesEvent {
  final String noteId;
  final String title;
  final String content;
  final List<Map<String, dynamic>>? checklistItems;

  const NotesUpdateRequested({
    required this.noteId,
    required this.title,
    required this.content,
    this.checklistItems,
  });

  @override
  List<Object> get props => [noteId, title, content, checklistItems ?? []];
}

class NotesDeleteRequested extends NotesEvent {
  final String noteId;

  const NotesDeleteRequested({required this.noteId});

  @override
  List<Object> get props => [noteId];
}

class NotesSyncRequested extends NotesEvent {
  final bool? isGuest;

  const NotesSyncRequested({this.isGuest});

  @override
  List<Object> get props => [isGuest ?? false];
}

class NotesAddCollaboratorRequested extends NotesEvent {
  final String noteId;
  final String email;
  final String permission;

  const NotesAddCollaboratorRequested({
    required this.noteId,
    required this.email,
    required this.permission,
  });

  @override
  List<Object> get props => [noteId, email, permission];
}

class NotesRemoveCollaboratorRequested extends NotesEvent {
  final String noteId;
  final String email;

  const NotesRemoveCollaboratorRequested({
    required this.noteId,
    required this.email,
  });

  @override
  List<Object> get props => [noteId, email];
}

class NotesRealtimeUpdateReceived extends NotesEvent {
  final List<NoteModel> notes;

  const NotesRealtimeUpdateReceived({required this.notes});

  @override
  List<Object> get props => [notes];
}

class NotesStartRealtimeSync extends NotesEvent {}

class NotesStopRealtimeSync extends NotesEvent {}

// Pin/Unpin
class NotesTogglePinRequested extends NotesEvent {
  final String noteId;

  const NotesTogglePinRequested({required this.noteId});

  @override
  List<Object> get props => [noteId];
}

// Archive/Unarchive
class NotesToggleArchiveRequested extends NotesEvent {
  final String noteId;

  const NotesToggleArchiveRequested({required this.noteId});

  @override
  List<Object> get props => [noteId];
}

// Favorite/Unfavorite
class NotesToggleFavoriteRequested extends NotesEvent {
  final String noteId;

  const NotesToggleFavoriteRequested({required this.noteId});

  @override
  List<Object> get props => [noteId];
}

// Color
class NotesUpdateColorRequested extends NotesEvent {
  final String noteId;
  final String? color;

  const NotesUpdateColorRequested({
    required this.noteId,
    this.color,
  });

  @override
  List<Object> get props => [noteId, color ?? ''];
}

// Tags
class NotesAddTagRequested extends NotesEvent {
  final String noteId;
  final String tag;

  const NotesAddTagRequested({
    required this.noteId,
    required this.tag,
  });

  @override
  List<Object> get props => [noteId, tag];
}

class NotesRemoveTagRequested extends NotesEvent {
  final String noteId;
  final String tag;

  const NotesRemoveTagRequested({
    required this.noteId,
    required this.tag,
  });

  @override
  List<Object> get props => [noteId, tag];
}

// Enable/Disable Sync
class NotesToggleSyncRequested extends NotesEvent {
  final String noteId;
  final bool enableSync;

  const NotesToggleSyncRequested({
    required this.noteId,
    required this.enableSync,
  });

  @override
  List<Object> get props => [noteId, enableSync];
}

// Delete with options
class NotesDeleteWithOptionsRequested extends NotesEvent {
  final String noteId;
  final bool deleteFromCloud;

  const NotesDeleteWithOptionsRequested({
    required this.noteId,
    required this.deleteFromCloud,
  });

  @override
  List<Object> get props => [noteId, deleteFromCloud];
}

// Fetch cloud notes when logging in
class NotesFetchCloudNotesRequested extends NotesEvent {}
