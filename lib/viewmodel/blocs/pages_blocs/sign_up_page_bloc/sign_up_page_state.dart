part of 'sign_up_page_bloc.dart';

@immutable
sealed class SignUpPageState {}

final class SignUpPageInitial extends SignUpPageState {}

final class SignUpPageLoading extends SignUpPageState {}

final class SignUpPageSuccess extends SignUpPageState {
  final User user;

  SignUpPageSuccess({required this.user});
}

final class SignUpPageFailure extends SignUpPageState {
  final String message;

  SignUpPageFailure({required this.message});
}

