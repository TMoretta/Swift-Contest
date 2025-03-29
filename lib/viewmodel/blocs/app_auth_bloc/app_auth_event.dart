part of 'app_auth_bloc.dart';

@immutable
sealed class AppAuthEvent {}

final class AppAuthChanged extends AppAuthEvent {
  final AppAuthChange appAuthChange;

  AppAuthChanged({required this.appAuthChange});
}

final class AppAuthSplashPageDelay extends AppAuthEvent {}

