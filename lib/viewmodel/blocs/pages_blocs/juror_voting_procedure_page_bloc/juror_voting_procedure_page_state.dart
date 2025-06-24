part of 'juror_voting_procedure_page_bloc.dart';

@immutable
final class JurorVotingProcedurePageState extends Equatable {
  final BlocStatus status;
  final JurorVotingProcedurePageEvent? sourceEvent;
  final String? message;
  final VotingSessionBundle? votingSessionBundle;

  const JurorVotingProcedurePageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.votingSessionBundle,
  });

  JurorVotingProcedurePageState copyWith({
    required BlocStatus status,
    JurorVotingProcedurePageEvent? sourceEvent,
    String? message,
    VotingSessionBundle? votingSessionBundle,
  }) {
    return JurorVotingProcedurePageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      votingSessionBundle: votingSessionBundle ?? this.votingSessionBundle,
    );
  }

  @override
  List<Object?> get props => [
    status,
    sourceEvent,
    message,
    votingSessionBundle,
  ];
}
