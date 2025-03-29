part of 'sign_up_page_bloc.dart';

@immutable
sealed class SignUpPageEvent {}

final class SignUpPageSignUpWithEmailAndPassword extends SignUpPageEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  SignUpPageSignUpWithEmailAndPassword({required this.email, required this.password, required this.firstName, required this.lastName,});

}

