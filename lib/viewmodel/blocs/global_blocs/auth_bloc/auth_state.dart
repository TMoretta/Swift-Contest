part of 'auth_bloc.dart';

@immutable
final class AuthState extends Equatable {
  final BlocStatus blocStatus;
  final AuthStatus authStatus;
  final String? message;
  final User? user;
  final Profile? profile;

  const AuthState({
    required this.blocStatus,
    required this.authStatus,
    this.message,
    this.user,
    this.profile,
  });

  AuthState copyWith({
    required BlocStatus blocStatus,
    AuthStatus? authStatus,
    String? message,
    User? user,
    Profile? profile,
  }) {
    return AuthState(
      blocStatus: blocStatus,
      authStatus: authStatus ?? this.authStatus,
      message: message,
      user: user ?? this.user,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [authStatus, blocStatus, message, user, profile];
}
