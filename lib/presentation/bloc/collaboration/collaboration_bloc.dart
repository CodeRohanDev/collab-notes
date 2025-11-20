import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/realtime_collaboration_service.dart';
import '../../../data/models/presence_model.dart';

part 'collaboration_event.dart';
part 'collaboration_state.dart';

class CollaborationBloc extends Bloc<CollaborationEvent, CollaborationState> {
  final RealtimeCollaborationService _collaborationService;
  StreamSubscription? _noteSubscription;
  StreamSubscription? _presenceSubscription;
  Timer? _debounceTimer;

  CollaborationBloc({
    required RealtimeCollaborationService collaborationService,
  })  : _collaborationService = collaborationService,
        super(CollaborationInitial()) {
    on<CollaborationStartWatching>(_onStartWatching);
    on<CollaborationStopWatching>(_onStopWatching);
    on<CollaborationNoteUpdated>(_onNoteUpdated);
    on<CollaborationPresenceUpdated>(_onPresenceUpdated);
    on<CollaborationUpdateCursor>(_onUpdateCursor);
    on<CollaborationSendChanges>(_onSendChanges);
  }

  void _onStartWatching(
    CollaborationStartWatching event,
    Emitter<CollaborationState> emit,
  ) async {
    try {
      // Cancel existing subscriptions
      await _noteSubscription?.cancel();
      await _presenceSubscription?.cancel();

      // Start presence heartbeat
      _collaborationService.startPresenceHeartbeat(event.noteId);

      // Watch note changes
      _noteSubscription = _collaborationService
          .watchNoteChanges(event.noteId)
          .listen((noteData) {
        if (noteData != null) {
          add(CollaborationNoteUpdated(noteData: noteData));
        }
      });

      // Watch presence
      _presenceSubscription = _collaborationService
          .watchPresence(event.noteId)
          .listen((activeUsers) {
        add(CollaborationPresenceUpdated(activeUsers: activeUsers));
      });

      emit(CollaborationWatching(noteId: event.noteId));
    } catch (e) {
      emit(CollaborationError(message: e.toString()));
    }
  }

  void _onStopWatching(
    CollaborationStopWatching event,
    Emitter<CollaborationState> emit,
  ) async {
    await _noteSubscription?.cancel();
    await _presenceSubscription?.cancel();
    _debounceTimer?.cancel();

    if (state is CollaborationWatching) {
      final currentState = state as CollaborationWatching;
      await _collaborationService.stopPresenceHeartbeat(currentState.noteId);
    }

    emit(CollaborationInitial());
  }

  void _onNoteUpdated(
    CollaborationNoteUpdated event,
    Emitter<CollaborationState> emit,
  ) {
    if (state is CollaborationWatching) {
      final currentState = state as CollaborationWatching;
      emit(currentState.copyWith(
        remoteContent: event.noteData['content'] as String?,
        remoteTitle: event.noteData['title'] as String?,
        lastUpdate: DateTime.now(),
      ));
    }
  }

  void _onPresenceUpdated(
    CollaborationPresenceUpdated event,
    Emitter<CollaborationState> emit,
  ) {
    if (state is CollaborationWatching) {
      final currentState = state as CollaborationWatching;
      emit(currentState.copyWith(activeUsers: event.activeUsers));
    }
  }

  void _onUpdateCursor(
    CollaborationUpdateCursor event,
    Emitter<CollaborationState> emit,
  ) async {
    if (state is CollaborationWatching) {
      final currentState = state as CollaborationWatching;
      
      // Debounce cursor updates (send every 500ms max)
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _collaborationService.updatePresence(
          noteId: currentState.noteId,
          cursorPosition: event.cursorPosition,
          selectionStart: event.selectionStart,
          selectionEnd: event.selectionEnd,
        );
      });
    }
  }

  void _onSendChanges(
    CollaborationSendChanges event,
    Emitter<CollaborationState> emit,
  ) async {
    if (state is CollaborationWatching) {
      final currentState = state as CollaborationWatching;
      
      try {
        await _collaborationService.updateNoteContent(
          noteId: currentState.noteId,
          content: event.content,
          title: event.title,
        );
      } catch (e) {
        emit(CollaborationError(message: e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _noteSubscription?.cancel();
    _presenceSubscription?.cancel();
    _debounceTimer?.cancel();
    _collaborationService.dispose();
    return super.close();
  }
}
