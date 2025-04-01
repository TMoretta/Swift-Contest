part of 'contest_role_bloc.dart';

sealed class ContestRoleEvent extends Equatable {
  const ContestRoleEvent();
}

final class ContestRoleInitRole extends ContestRoleEvent {
  @override
  List<Object?> get props => [];
}

final class ContestRoleChangeRole extends ContestRoleEvent {
  final ContestRole contestRole;

  const ContestRoleChangeRole({required this.contestRole});

  @override
  List<Object?> get props => [contestRole];
}

final class ContestRoleTriggerListener extends ContestRoleEvent {
  @override
  List<Object?> get props => [];
}
