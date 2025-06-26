part of 'simple_juror_voting_procedure_page_bloc.dart';

@immutable
final class SimpleJurorVotingProcedurePageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final SimpleJurorVotingProcedurePageEvent? sourceEvent;
  final VotingSessionProcedureBundle? votingSessionProcedureBundle;

  const SimpleJurorVotingProcedurePageState({
    required this.status,
    this.message,
    this.sourceEvent,
    this.votingSessionProcedureBundle,
  });

  SimpleJurorVotingProcedurePageState copyWith({
    required BlocStatus status,
    String? message,
    SimpleJurorVotingProcedurePageEvent? sourceEvent,
    VotingSessionProcedureBundle? votingSessionProcedureBundle,
  }) {
    return SimpleJurorVotingProcedurePageState(
      status: status,
      message: message,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      votingSessionProcedureBundle: votingSessionProcedureBundle ?? this.votingSessionProcedureBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        sourceEvent,
        votingSessionProcedureBundle,
      ];
}
