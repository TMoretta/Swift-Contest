enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

extension AuthStatusX on AuthStatus {
  bool get isInitial => this == AuthStatus.initial;

  bool get isAuthenticated => this == AuthStatus.authenticated;

  bool get isUnauthenticated => this == AuthStatus.unauthenticated;
}
