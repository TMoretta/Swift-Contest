part of 'sign_in_page_bloc.dart';

@immutable
sealed class SignInPageState {}

final class SignInPageInitial extends SignInPageState {}

final class SignInPageLoading extends SignInPageState {}

final class SignInPageSuccess extends SignInPageState {
  final User user;

  SignInPageSuccess({required this.user});
}

final class SignInPageFailure extends SignInPageState {
  final String message;

  SignInPageFailure({required this.message});
}
