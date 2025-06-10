part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

final class AuthInit extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class AuthInitWithDelay extends AuthEvent {
  final int delay;

  const AuthInitWithDelay({required this.delay});

  @override
  List<Object?> get props => [];
}

final class AuthFetchUser extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class AuthFetchProfile extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class AuthFetchUserAndProfile extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class AuthSignOut extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class AuthEditPrefTheme extends AuthEvent {
  final Profile profile;
  final AppTheme prefTheme;

  const AuthEditPrefTheme({required this.profile, required this.prefTheme});

  @override
  List<Object?> get props => [profile, prefTheme];
}

final class AuthEditPrefRole extends AuthEvent {
  final Profile profile;
  final ContestRole prefRole;

  const AuthEditPrefRole({required this.profile, required this.prefRole});

  @override
  List<Object?> get props => [profile, prefRole];
}

final class AuthEditFullName extends AuthEvent {
  final String fullName;

  const AuthEditFullName({required this.fullName});

  @override
  List<Object?> get props => [fullName];
}
