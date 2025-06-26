part of 'simple_juror_voting_procedure_page_bloc.dart';

sealed class SimpleJurorVotingProcedurePageEvent extends Equatable {
  const SimpleJurorVotingProcedurePageEvent();
}

final class SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure
    extends SimpleJurorVotingProcedurePageEvent {
  final String votingSessionId;

  const SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure({
    required this.votingSessionId,
  });

  @override
  List<Object?> get props => [votingSessionId];
}

final class SimpleJurorVotingProcedurePageSubmitVotes extends SimpleJurorVotingProcedurePageEvent {
  final VotingSession votingSession;
  final String simpleJurorId;
  final Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap;

  const SimpleJurorVotingProcedurePageSubmitVotes({
    required this.votingSession,
    required this.simpleJurorId,
    required this.votesPerParticipantMap,
  });

  @override
  List<Object?> get props => [votingSession, simpleJurorId, votesPerParticipantMap];
}
