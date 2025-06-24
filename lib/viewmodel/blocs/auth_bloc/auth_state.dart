part of 'auth_bloc.dart';

@immutable
final class AuthState extends Equatable {
  final BlocStatus blocStatus;
  final AuthStatus authStatus;
  final AuthEvent? sourceEvent;
  final String? message;
  final User? user;
  final Profile? profile;
  final List<Message>? messages;

  const AuthState({
    required this.blocStatus,
    required this.authStatus,
    this.sourceEvent,
    this.message,
    this.user,
    this.profile,
    this.messages,
  });

  AuthState copyWith({
    required BlocStatus blocStatus,
    AuthStatus? authStatus,
    AuthEvent? sourceEvent,
    String? message,
    User? user,
    Profile? profile,
    List<Message>? messages,
  }) {
    return AuthState(
      blocStatus: blocStatus,
      authStatus: authStatus ?? this.authStatus,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [
        authStatus,
        blocStatus,
        sourceEvent,
        message,
        user,
        profile,
        messages,
      ];
}
