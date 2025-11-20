part of 'collaboration_bloc.dart';

abstract class CollaborationState extends Equatable {
  const CollaborationState();

  @override
  List<Object?> get props => [];
}

class CollaborationInitial extends CollaborationState {}

class CollaborationWatching extends CollaborationState {
  final String noteId;
  final List<PresenceModel> activeUsers;
  final String? remoteContent;
  final String? remoteTitle;
  final DateTime? lastUpdate;
  final bool hasConflict;

  const CollaborationWatching({
    required this.noteId,
    this.activeUsers = const [],
    this.remoteContent,
    this.remoteTitle,
    this.lastUpdate,
    this.hasConflict = false,
  });

  CollaborationWatching copyWith({
    String? noteId,
    List<PresenceModel>? activeUsers,
    String? remoteContent,
    String? remoteTitle,
    DateTime? lastUpdate,
    bool? hasConflict,
  }) {
    return CollaborationWatching(
      noteId: noteId ?? this.noteId,
      activeUsers: activeUsers ?? this.activeUsers,
      remoteContent: remoteContent ?? this.remoteContent,
      remoteTitle: remoteTitle ?? this.remoteTitle,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      hasConflict: hasConflict ?? this.hasConflict,
    );
  }

  @override
  List<Object?> get props => [
        noteId,
        activeUsers,
        remoteContent,
        remoteTitle,
        lastUpdate,
        hasConflict,
      ];
}

class CollaborationError extends CollaborationState {
  final String message;

  const CollaborationError({required this.message});

  @override
  List<Object> get props => [message];
}
