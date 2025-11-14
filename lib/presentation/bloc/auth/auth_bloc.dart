import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/preferences_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final PreferencesService _preferencesService;

  AuthBloc({
    required AuthRepository authRepository,
    required PreferencesService preferencesService,
  })  : _authRepository = authRepository,
        _preferencesService = preferencesService,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthContinueAsGuestRequested>(_onContinueAsGuest);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthMigrateGuestDataRequested>(_onMigrateGuestData);
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user != null) {
      await _preferencesService.setGuestMode(false);
      emit(AuthAuthenticated(
        user: UserModel(
          id: user.uid,
          email: user.email!,
          displayName: user.displayName ?? 'User',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
        ),
        isGuest: false,
      ));
    } else if (_preferencesService.isGuestMode) {
      final guestId = _preferencesService.guestUserId ?? const Uuid().v4();
      await _preferencesService.setGuestUserId(guestId);
      emit(AuthAuthenticated(
        user: UserModel(
          id: guestId,
          email: 'guest@local',
          displayName: 'Guest User',
          photoUrl: null,
          createdAt: DateTime.now(),
        ),
        isGuest: true,
      ));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  void _onSignInWithGoogle(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final currentState = state;
      String? guestUserId;
      
      if (currentState is AuthAuthenticated && currentState.isGuest) {
        guestUserId = currentState.user.id;
      }

      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        await _preferencesService.setGuestMode(false);
        
        if (guestUserId != null) {
          add(AuthMigrateGuestDataRequested(guestUserId: guestUserId));
        }
        
        emit(AuthAuthenticated(user: user, isGuest: false));
      } else {
        if (currentState is AuthAuthenticated && currentState.isGuest) {
          emit(currentState);
        } else {
          emit(AuthUnauthenticated());
        }
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
      final currentState = state;
      if (currentState is AuthAuthenticated && currentState.isGuest) {
        emit(currentState);
      } else {
        emit(AuthUnauthenticated());
      }
    }
  }

  void _onContinueAsGuest(
    AuthContinueAsGuestRequested event,
    Emitter<AuthState> emit,
  ) async {
    final guestId = const Uuid().v4();
    await _preferencesService.setGuestMode(true);
    await _preferencesService.setGuestUserId(guestId);
    
    emit(AuthAuthenticated(
      user: UserModel(
        id: guestId,
        email: 'guest@local',
        displayName: 'Guest User',
        photoUrl: null,
        createdAt: DateTime.now(),
      ),
      isGuest: true,
    ));
  }

  void _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    await _preferencesService.clearGuestData();
    emit(AuthUnauthenticated());
  }

  void _onMigrateGuestData(
    AuthMigrateGuestDataRequested event,
    Emitter<AuthState> emit,
  ) async {
    // This will be handled by NotesRepository to migrate guest notes
    // to the authenticated user's account
  }
}
