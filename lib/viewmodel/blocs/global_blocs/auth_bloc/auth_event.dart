part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

final class AuthChanged extends AuthEvent {
  final AuthChange authChange;

  const AuthChanged({required this.authChange});

  @override
  List<Object?> get props => [authChange];
}

final class AuthCheckInitialSessionWithDelay extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class AuthUnauthenticate extends AuthEvent {
  @override
  List<Object?> get props => [];
}

