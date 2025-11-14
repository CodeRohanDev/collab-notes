import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/note_model.dart';
import '../../../data/repositories/notes_repository.dart';
import '../../../core/constants/app_constants.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository _notesRepository;
  final String userId;

  NotesBloc({
    required NotesRepository notesRepository,
    required this.userId,
  })  : _notesRepository = notesRepository,
        super(NotesInitial()) {
    on<NotesLoadRequested>(_onLoadNotes);
    on<NotesCreateRequested>(_onCreateNote);
    on<NotesUpdateRequested>(_onUpdateNote);
    on<NotesDeleteRequested>(_onDeleteNote);
    on<NotesSyncRequested>(_onSyncNotes);
  }

  void _onLoadNotes(
    NotesLoadRequested event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    try {
      final localNotes = _notesRepository.getAllLocalNotes();
      emit(NotesLoaded(notes: localNotes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  void _onCreateNote(
    NotesCreateRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final note = NoteModel(
        id: const Uuid().v4(),
        title: event.title,
        content: event.content,
        ownerId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: AppConstants.syncPending,
        checklistItems: event.checklistItems ?? [],
      );

      await _notesRepository.saveNoteLocally(note);
      
      final notes = _notesRepository.getAllLocalNotes();
      emit(NotesLoaded(notes: notes));

      add(NotesSyncRequested());
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  void _onUpdateNote(
    NotesUpdateRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final existingNote = _notesRepository.getNoteById(event.noteId);
      if (existingNote != null) {
        final updatedNote = existingNote.copyWith(
          title: event.title,
          content: event.content,
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncPending,
          checklistItems: event.checklistItems,
        );

        await _notesRepository.saveNoteLocally(updatedNote);
        
        final notes = _notesRepository.getAllLocalNotes();
        emit(NotesLoaded(notes: notes));

        add(NotesSyncRequested());
      }
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  void _onDeleteNote(
    NotesDeleteRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _notesRepository.deleteNoteLocally(event.noteId);
      await _notesRepository.deleteNoteFromCloud(event.noteId);
      
      final notes = _notesRepository.getAllLocalNotes();
      emit(NotesLoaded(notes: notes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  void _onSyncNotes(
    NotesSyncRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final isGuest = event.isGuest ?? false;
      await _notesRepository.syncAllPendingNotes(isGuest: isGuest);
      final notes = _notesRepository.getAllLocalNotes();
      emit(NotesLoaded(notes: notes));
    } catch (e) {
      // Sync failed, but don't show error to user
    }
  }
}
