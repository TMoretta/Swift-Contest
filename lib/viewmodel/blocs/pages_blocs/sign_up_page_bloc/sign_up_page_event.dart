part of 'sign_up_page_bloc.dart';

sealed class SignUpPageEvent extends Equatable {
  const SignUpPageEvent();
}

final class SignUpWithEmailAndPassword extends SignUpPageEvent {
  final String email;
  final String password;
  final String fullName;

  const SignUpWithEmailAndPassword({
    required this.email,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object> get props => [email, password, fullName];
}

final class SignUpWithEmail extends SignUpPageEvent {
  final String email;
  final String fullName;

  const SignUpWithEmail({required this.email, required this.fullName});

  @override
  List<Object> get props => [email,fullName];
}
