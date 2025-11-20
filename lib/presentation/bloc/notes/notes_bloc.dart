import 'dart:async';
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
  StreamSubscription<List<NoteModel>>? _realtimeSyncSubscription;

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
    on<NotesAddCollaboratorRequested>(_onAddCollaborator);
    on<NotesRemoveCollaboratorRequested>(_onRemoveCollaborator);
    on<NotesRealtimeUpdateReceived>(_onRealtimeUpdate);
    on<NotesStartRealtimeSync>(_onStartRealtimeSync);
    on<NotesStopRealtimeSync>(_onStopRealtimeSync);
    on<NotesTogglePinRequested>(_onTogglePin);
    on<NotesToggleArchiveRequested>(_onToggleArchive);
    on<NotesToggleFavoriteRequested>(_onToggleFavorite);
    on<NotesUpdateColorRequested>(_onUpdateColor);
    on<NotesAddTagRequested>(_onAddTag);
    on<NotesRemoveTagRequested>(_onRemoveTag);
    on<NotesToggleSyncRequested>(_onToggleSync);
    on<NotesDeleteWithOptionsRequested>(_onDeleteWithOptions);
    on<NotesFetchCloudNotesRequested>(_onFetchCloudNotes);
    on<NotesFetchSharedNoteRequested>(_onFetchSharedNote);
    on<NotesAcceptCollaborationRequested>(_onAcceptCollaboration);
    
    // Load notes immediately after all handlers are registered
    add(NotesLoadRequested());
  }

  @override
  Future<void> close() {
    _realtimeSyncSubscription?.cancel();
    return super.close();
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
      // Default behavior: delete locally only
      await _notesRepository.deleteNote(event.noteId, deleteFromCloud: false);
      
      final notes = _notesRepository.getAllLocalNotes();
      emit(NotesLoaded(notes: notes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  void _onDeleteWithOptions(
    NotesDeleteWithOptionsRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _notesRepository.deleteNote(
        event.noteId,
        deleteFromCloud: event.deleteFromCloud,
      );
      
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

  void _onAddCollaborator(
    NotesAddCollaboratorRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _notesRepository.addCollaborator(event.noteId, event.email);
      final notes = _notesRepository.getAllLocalNotes();
      emit(NotesLoaded(notes: notes));
    } catch (e) {
      emit(NotesError(message: 'Failed to add collaborator: ${e.toString()}'));
    }
  }

  void _onRemoveCollaborator(
    NotesRemoveCollaboratorRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _notesRepository.removeCollaborator(event.noteId, event.email);
      final notes = _notesRepository.getAllLocalNotes();
      emit(NotesLoaded(notes: notes));
    } catch (e) {
      emit(NotesError(message: 'Failed to remove collaborator: ${e.toString()}'));
    }
  }

  void _onRealtimeUpdate(
    NotesRealtimeUpdateReceived event,
    Emitter<NotesState> emit,
  ) {
    // Merge cloud notes with local notes instead of replacing
    final localNotes = _notesRepository.getAllLocalNotes();
    final cloudNoteIds = event.notes.map((n) => n.id).toSet();
    
    // Keep local notes that aren't in cloud (e.g., guest notes, local-only notes)
    final localOnlyNotes = localNotes.where((n) => !cloudNoteIds.contains(n.id)).toList();
    
    // Combine cloud notes with local-only notes
    final allNotes = [...event.notes, ...localOnlyNotes];
    
    emit(NotesLoaded(notes: allNotes));
  }

  void _onStartRealtimeSync(
    NotesStartRealtimeSync event,
    Emitter<NotesState> emit,
  ) {
    _realtimeSyncSubscription?.cancel();
    
    _realtimeSyncSubscription = _notesRepository
        .watchAllAccessibleNotes(userId)
        .listen((notes) {
      add(NotesRealtimeUpdateReceived(notes: notes));
    });
  }

  void _onStopRealtimeSync(
    NotesStopRealtimeSync event,
    Emitter<NotesState> emit,
  ) {
    _realtimeSyncSubscription?.cancel();
    _realtimeSyncSubscription = null;
  }

  void _onTogglePin(
    NotesTogglePinRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final note = _notesRepository.getNoteById(event.noteId);
      if (note != null) {
        final updatedNote = note.copyWith(
          isPinned: !note.isPinned,
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncPending,
        );
        await _notesRepository.saveNoteLocally(updatedNote);
        await _notesRepository.syncNoteToCloud(updatedNote);
        
        final notes = _notesRepository.getAllLocalNotes();
        emit(NotesLoaded(notes: notes));
      }
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  void _onToggleArchive(
    NotesToggleArchiveRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final note = _notesRepository.getNoteById(event.noteId);
      if (note != null) {
        final updatedNote = note.copyWith(
          isArchived: !note.isArchived,
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncPending,
        );
        await _notesRepository.saveNoteLocally(updatedNote);
        await _notesRepository.syncNoteToCloud(updatedNote);
        
        final notes = _notesRepository.getAllLocalNotes();
        emit(NotesLoaded(notes: notes));
      }
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  void _onToggleFavorite(
    NotesToggleFavoriteRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final note = _notesRepository.getNoteById(event.noteId);
      if (note != null) {
        final updatedNote = note.copyWith(
          isFavorite: !note.isFavorite,
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncPending,
        );
        await _notesRepository.saveNoteLocally(updatedNote);
        await _notesRepository.syncNoteToCloud(updatedNote);
        
        final notes = _notesRepository.getAllLocalNotes();
        emit(NotesLoaded(notes: notes));
      }
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  void _onUpdateColor(
    NotesUpdateColorRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final note = _notesRepository.getNoteById(event.noteId);
      if (note != null) {
        final updatedNote = note.copyWith(
          color: event.color,
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncPending,
        );
        await _notesRepository.saveNoteLocally(updatedNote);
        await _notesRepository.syncNoteToCloud(updatedNote);
        
        final notes = _notesRepository.getAllLocalNotes();
        emit(NotesLoaded(notes: notes));
      }
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  void _onAddTag(
    NotesAddTagRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final note = _notesRepository.getNoteById(event.noteId);
      if (note != null) {
        final tags = List<String>.from(note.tags);
        if (!tags.contains(event.tag)) {
          tags.add(event.tag);
        }
        final updatedNote = note.copyWith(
          tags: tags,
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncPending,
        );
        await _notesRepository.saveNoteLocally(updatedNote);
        await _notesRepository.syncNoteToCloud(updatedNote);
        
        final notes = _notesRepository.getAllLocalNotes();
        emit(NotesLoaded(notes: notes));
      }
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  void _onRemoveTag(
    NotesRemoveTagRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final note = _notesRepository.getNoteById(event.noteId);
      if (note != null) {
        final tags = List<String>.from(note.tags);
        tags.remove(event.tag);
        final updatedNote = note.copyWith(
          tags: tags,
          updatedAt: DateTime.now(),
          syncStatus: AppConstants.syncPending,
        );
        await _notesRepository.saveNoteLocally(updatedNote);
        await _notesRepository.syncNoteToCloud(updatedNote);
        
        final notes = _notesRepository.getAllLocalNotes();
        emit(NotesLoaded(notes: notes));
      }
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  void _onToggleSync(
    NotesToggleSyncRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      if (event.enableSync) {
        await _notesRepository.enableSyncForNote(event.noteId);
      } else {
        await _notesRepository.disableSyncForNote(event.noteId);
      }
      
      final notes = _notesRepository.getAllLocalNotes();
      emit(NotesLoaded(notes: notes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  void _onFetchCloudNotes(
    NotesFetchCloudNotesRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      // This will fetch cloud notes and merge with local
      // Only synced notes will be fetched
      final notes = _notesRepository.getAllLocalNotes();
      emit(NotesLoaded(notes: notes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  void _onFetchSharedNote(
    NotesFetchSharedNoteRequested event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    try {
      final note = await _notesRepository.fetchSharedNote(event.noteId);
      if (note == null) {
        emit(const NotesError(message: 'Note not found'));
        return;
      }
      
      final notes = _notesRepository.getAllLocalNotes();
      emit(NotesLoaded(notes: notes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  void _onAcceptCollaboration(
    NotesAcceptCollaborationRequested event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    try {
      await _notesRepository.acceptCollaborationInvite(event.noteId);
      
      final notes = _notesRepository.getAllLocalNotes();
      emit(NotesLoaded(notes: notes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }
}
