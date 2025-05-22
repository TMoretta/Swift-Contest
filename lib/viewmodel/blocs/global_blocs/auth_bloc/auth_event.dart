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

final class AuthSignInWithEmail extends AuthEvent {
  final String email;

  const AuthSignInWithEmail({required this.email});

  @override
  List<Object?> get props => [email];
}

final class AuthSignUpWithEmail extends AuthEvent {
  final String email;
  final String fullName;

  const AuthSignUpWithEmail({required this.email, required this.fullName});

  @override
  List<Object?> get props => [email, fullName];
}

final class AuthSignInVerifyOtp extends AuthEvent {
  final String email;
  final String otp;

  const AuthSignInVerifyOtp({required this.email, required this.otp});

  @override
  List<Object?> get props => [email,otp];
}

final class AuthSignUpVerifyOtp extends AuthEvent {
  final String email;
  final String otp;

  const AuthSignUpVerifyOtp({required this.email, required this.otp});

  @override
  List<Object?> get props => [email,otp];
}


final class AuthSignOut extends AuthEvent {
  @override
  List<Object?> get props => [];
}

final class AuthEditFullName extends AuthEvent {
  final String fullName;

  const AuthEditFullName({required this.fullName});

  @override
  List<Object?> get props => [fullName];
}

final class AuthEditPrefTheme extends AuthEvent {
  final AppTheme prefTheme;

  const AuthEditPrefTheme({required this.prefTheme});

  @override
  List<Object?> get props => [prefTheme];
}

final class AuthSignInWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmailAndPassword({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

final class AuthSignUpWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;
  final String fullName;

  const AuthSignUpWithEmailAndPassword({
    required this.email,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [email, password, fullName];
}

// final class AuthClear extends AuthEvent {
//   @override
//   List<Object?> get props => [];
// }

// final class AuthChanged extends AuthEvent {
//   final AuthStateChange authChange;
//
//   const AuthChanged({required this.authChange});
//
//   @override
//   List<Object?> get props => [authChange];
// }
//
// final class AuthCheckSession extends AuthEvent {
//   @override
//   List<Object?> get props => [];
// }

// final class AuthUnauthenticate extends AuthEvent {
//   @override
//   List<Object?> get props => [];
// }
