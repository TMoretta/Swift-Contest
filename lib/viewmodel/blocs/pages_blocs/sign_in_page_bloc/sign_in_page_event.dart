part of 'sign_in_page_bloc.dart';

@immutable
sealed class SignInPageEvent {}

final class SignInPageSignInWithEmailAndPassword extends SignInPageEvent {
  final String email;
  final String password;

  SignInPageSignInWithEmailAndPassword({required this.email, required this.password});
}

