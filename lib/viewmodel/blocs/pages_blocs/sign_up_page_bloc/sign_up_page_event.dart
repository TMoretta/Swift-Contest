part of 'sign_up_page_bloc.dart';

sealed class SignUpPageEvent extends Equatable {
  const SignUpPageEvent();
}

final class SignUpPageSignUpWithEmailAndPassword extends SignUpPageEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  const SignUpPageSignUpWithEmailAndPassword({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName];
}
