part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

final class AuthInit extends AuthEvent {
  final int delay;

  const AuthInit({required this.delay});

  @override
  List<Object?> get props => [];
}

final class AuthRefresh extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class AuthFetchUserInfo extends AuthEvent {
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

final class AuthFetchProfileMessages extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class AuthSignOut extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class AuthEditPrefTheme extends AuthEvent {
  final AppTheme prefTheme;

  const AuthEditPrefTheme({required this.prefTheme});

  @override
  List<Object?> get props => [prefTheme];
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

final class AuthMarkMessageAsRead extends AuthEvent {
  final String messageId;

  const AuthMarkMessageAsRead({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

final class AuthDeleteAccount extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class AuthDeleteMessage extends AuthEvent {
  final String messageId;

  const AuthDeleteMessage({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

final class AuthDeleteAllMessages extends AuthEvent {
  final String profileId;

  const AuthDeleteAllMessages({required this.profileId});

  @override
  List<Object?> get props => [profileId];
}
