part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInWithGoogleRequested extends AuthEvent {}

class AuthContinueAsGuestRequested extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}

class AuthMigrateGuestDataRequested extends AuthEvent {
  final String guestUserId;

  const AuthMigrateGuestDataRequested({required this.guestUserId});

  @override
  List<Object> get props => [guestUserId];
}
