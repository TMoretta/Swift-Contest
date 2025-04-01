part of 'contest_role_bloc.dart';

@immutable
final class ContestRoleState extends Equatable {
  final BlocStatus status;
  final String? message;
  final ContestRole? contestRole;

  const ContestRoleState({
    required this.status,
    this.message,
    this.contestRole,
  });

  ContestRoleState copyWith({
    required BlocStatus status,
    String? message,
    ContestRole? contestRole,
  }) {
    return ContestRoleState(
      status: status,
      message: message,
      contestRole: contestRole ?? this.contestRole,
    );
  }

  @override
  List<Object?> get props => [status,message,contestRole];
}
