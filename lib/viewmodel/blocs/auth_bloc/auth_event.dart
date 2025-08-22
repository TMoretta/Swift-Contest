part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

final class AuthFetch extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class AuthSignOut extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class AuthEditPrefRole extends AuthEvent {
  final ContestRole prefRole;

  const AuthEditPrefRole({required this.prefRole});

  @override
  List<Object?> get props => [prefRole];
}

final class AuthEditFullName extends AuthEvent {
  final String fullName;

  const AuthEditFullName({required this.fullName});

  @override
  List<Object?> get props => [fullName];
}

final class AuthDeleteAccount extends AuthEvent {
  @override
  List<Object?> get props => [];
}

