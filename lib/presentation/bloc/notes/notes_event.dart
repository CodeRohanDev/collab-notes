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
