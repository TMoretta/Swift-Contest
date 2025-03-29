part of 'app_contest_role_bloc.dart';

@immutable
sealed class AppContestRoleState {}

final class AppContestRoleInitial extends AppContestRoleState {}

final class AppContestRoleLoading extends AppContestRoleState {}

final class AppContestRoleSuccess extends AppContestRoleState {
  final ContestRole appContestRole;

  AppContestRoleSuccess({required this.appContestRole});
}

final class AppContestRoleFailure extends AppContestRoleState {
  final String message;

  AppContestRoleFailure({required this.message});
}

// final BlocStatus status;
// final ContestRole? appContestRole;
// final String? message;
//
// const AppContestRoleState({
// required this.status,
// this.appContestRole,
// this.message,
// });
//
// AppContestRoleState copyWith({
// required BlocStatus status,
// ContestRole? appContestRole,
// String? message,
// }) {
// return AppContestRoleState(
// status: status,
// appContestRole: appContestRole ?? this.appContestRole,
// message: message,
// );
// }
