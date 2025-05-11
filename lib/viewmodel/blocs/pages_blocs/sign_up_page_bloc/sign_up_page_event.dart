part of 'sign_up_page_bloc.dart';

sealed class SignUpPageEvent extends Equatable {
  const SignUpPageEvent();
}

final class SignUpPageSignUpWithEmailAndPassword extends SignUpPageEvent {
  final String email;
  final String password;
  final String fullName;

  const SignUpPageSignUpWithEmailAndPassword({
    required this.email,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [email, password, fullName];
}
