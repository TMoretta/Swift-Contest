part of 'app_auth_bloc.dart';

@immutable
sealed class AppAuthState {}

final class AppAuthInitial extends AppAuthState {}

final class AppAuthAuthenticated extends AppAuthState {
  final my.User user;

  AppAuthAuthenticated({required this.user});
}

final class AppAuthUnauthenticated extends AppAuthState {}
