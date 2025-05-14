part of 'simple_juror_voting_procedure_page_bloc.dart';

@immutable
sealed class SimpleJurorVotingProcedurePageEvent extends Equatable {
  const SimpleJurorVotingProcedurePageEvent();
}

final class SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure extends SimpleJurorVotingProcedurePageEvent {
  final VotingSession votingSession;
  final VotingSessionSimpleJuror votingSessionSimpleJuror;

  const SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure({
    required this.votingSession,
    required this.votingSessionSimpleJuror,
  });

  @override
  List<Object?> get props => [votingSession, votingSessionSimpleJuror,];
}

final class SimpleJurorVotingProcedurePageSubmitVotes extends SimpleJurorVotingProcedurePageEvent {
  final String votingSessionId;
  final VotingSessionSimpleJuror votingSessionSimpleJuror;
  final Map<VotingSessionParticipant, Map<VotingFormField, String>> votesPerParticipantMap;

  const SimpleJurorVotingProcedurePageSubmitVotes({
    required this.votingSessionSimpleJuror,
    required this.votingSessionId,
    required this.votesPerParticipantMap,
  });

  @override
  List<Object?> get props => [votingSessionSimpleJuror, votingSessionId, votesPerParticipantMap];
}
