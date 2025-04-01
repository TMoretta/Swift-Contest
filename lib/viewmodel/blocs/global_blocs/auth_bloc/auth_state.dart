part of 'auth_bloc.dart';

@immutable
final class AuthState extends Equatable {
  final AuthStatus status;
  final String? message;
  final my.User? user;
  final Profile? profile;

  const AuthState({
    required this.status,
    this.message,
    this.user,
    this.profile,
  });

  AuthState copyWith({
    required AuthStatus status,
    String? message,
    my.User? user,
    Profile? profile,
  }) {
    return AuthState(
      status: status,
      message: message,
      user: user ?? this.user,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [status, message, user, profile];
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

extension AuthStatusX on AuthStatus {
  bool get isInitial => this == AuthStatus.initial;
  bool get isLoading => this == AuthStatus.loading;
  bool get isAuthenticated => this == AuthStatus.authenticated;
  bool get isUnauthenticated => this == AuthStatus.unauthenticated;
}

// final class AuthInitial extends AuthState {
//   @override
//   List<Object> get props => [];
// }
//
// final class AuthLoading extends AuthState {
//   @override
//   List<Object> get props => [];
// }
//
// final class AuthAuthenticated extends AuthState {
//   final my.User user;
//
//   const AuthAuthenticated({required this.user});
//
//   @override
//   List<Object> get props => [user];
// }
//
// final class AuthUnauthenticated extends AuthState {
//   @override
//   List<Object> get props => [];
// }
