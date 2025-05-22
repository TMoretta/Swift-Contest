part of 'sign_in_page_bloc.dart';

sealed class SignInPageEvent extends Equatable {
  const SignInPageEvent();
}

// final class SignInPageSignInWithEmailAndPassword extends SignInPageEvent {
//   final String email;
//   final String password;
//
//   const SignInPageSignInWithEmailAndPassword({required this.email, required this.password});
//
//   @override
//   List<Object?> get props => [email, password];
// }

final class SignInPageVoteAsSimpleJuror extends SignInPageEvent {
  final String fullName;
  final String votingSessionToken;

  const SignInPageVoteAsSimpleJuror({required this.fullName, required this.votingSessionToken});

  @override
  List<Object?> get props => [fullName, votingSessionToken];
}
