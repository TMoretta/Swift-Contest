part of 'auth_bloc.dart';

@immutable
final class AuthState extends Equatable {
  final AuthStatus status;
  final String? message;
  final my.User? user;

  const AuthState({
    required this.status,
    this.message,
    this.user,
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
    );
  }

  @override
  List<Object?> get props => [status, message, user];
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
