part of 'sign_in_page_bloc.dart';

sealed class SignInPageEvent extends Equatable {
  const SignInPageEvent();
}

final class SignInWithEmailAndPassword extends SignInPageEvent {
  final String email;
  final String password;

  const SignInWithEmailAndPassword({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

final class SignInWithEmail extends SignInPageEvent {
  final String email;

  const SignInWithEmail({required this.email});

  @override
  List<Object> get props => [email];
}

final class SignInPageVoteAsSimpleJuror extends SignInPageEvent {
  final String fullName;
  final String token;

  const SignInPageVoteAsSimpleJuror({
    required this.fullName,
    required this.token,
  });

  @override
  List<Object?> get props => [fullName, token];
}

final class SignInPageAccessVotingAsSimpleJuror extends SignInPageEvent {
  final String token;

  const SignInPageAccessVotingAsSimpleJuror({
    required this.token,
  });

  @override
  List<Object?> get props => [token];
}

final class SignInPageAuthenticateSimpleJuror extends SignInPageEvent {
  final String fullName;

  const SignInPageAuthenticateSimpleJuror({
    required this.fullName,
  });

  @override
  List<Object?> get props => [fullName];
}
