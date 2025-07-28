part of 'juror_voting_procedure_page_bloc.dart';

@immutable
final class JurorVotingProcedurePageState extends Equatable {
  final BlocStatus status;
  final JurorVotingProcedurePageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final VotingSessionProcedureBundle? votingSessionProcedureBundle;
  final VotingSessionJuration? ownVotingSessionJuration;

  const JurorVotingProcedurePageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.votingSessionProcedureBundle,
    this.ownVotingSessionJuration,
  });

  JurorVotingProcedurePageState copyWith({
    required BlocStatus status,
    JurorVotingProcedurePageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    VotingSessionProcedureBundle? votingSessionProcedureBundle,
    VotingSessionJuration? ownVotingSessionJuration,
  }) {
    return JurorVotingProcedurePageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      votingSessionProcedureBundle:
          votingSessionProcedureBundle ?? this.votingSessionProcedureBundle,
      ownVotingSessionJuration: ownVotingSessionJuration ?? this.ownVotingSessionJuration,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        votingSessionProcedureBundle,
        ownVotingSessionJuration,
      ];
}
