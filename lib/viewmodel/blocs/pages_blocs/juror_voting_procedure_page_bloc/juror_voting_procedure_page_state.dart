part of 'juror_voting_procedure_page_bloc.dart';

@immutable
final class JurorVotingProcedurePageState extends Equatable {
  final BlocStatus status;
  final JurorVotingProcedurePageEvent? sourceEvent;
  final String? message;
  final VotingSessionProcedureBundle? votingSessionProcedureBundle;

  const JurorVotingProcedurePageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.votingSessionProcedureBundle,
  });

  JurorVotingProcedurePageState copyWith({
    required BlocStatus status,
    JurorVotingProcedurePageEvent? sourceEvent,
    String? message,
    VotingSessionProcedureBundle? votingSessionProcedureBundle,
  }) {
    return JurorVotingProcedurePageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      votingSessionProcedureBundle:
          votingSessionProcedureBundle ?? this.votingSessionProcedureBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
        votingSessionProcedureBundle,
      ];
}
