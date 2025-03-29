part of 'app_contest_role_bloc.dart';

@immutable
sealed class AppContestRoleEvent {}

final class AppContestRoleInitRole extends AppContestRoleEvent {}

final class AppContestRoleChangeRole extends AppContestRoleEvent {
  final ContestRole contestRole;

  AppContestRoleChangeRole({required this.contestRole});
}

final class AppContestRoleTriggerListener extends AppContestRoleEvent {}
