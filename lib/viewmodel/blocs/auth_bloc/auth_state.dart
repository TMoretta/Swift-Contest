part of 'auth_bloc.dart';

@immutable
final class AuthState extends Equatable {
  final BlocStatus blocStatus;
  final AuthStatus authStatus;
  final AuthEvent? sourceEvent;
  final String? message;
  final AuthBundle? authBundle;

  const AuthState({
    required this.blocStatus,
    required this.authStatus,
    this.sourceEvent,
    this.message,
    this.authBundle,
  });

  AuthState copyWith({
    required BlocStatus blocStatus,
    AuthStatus? authStatus,
    AuthEvent? sourceEvent,
    String? message,
    AuthBundle? authBundle,
  }) {
    return AuthState(
      blocStatus: blocStatus,
      authStatus: authStatus ?? this.authStatus,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      authBundle: authBundle ?? this.authBundle,
    );
  }

  @override
  List<Object?> get props => [authStatus, blocStatus, sourceEvent, message, authBundle];
}
