part of 'juror_voting_procedure_page_bloc.dart';

sealed class JurorVotingProcedurePageEvent extends Equatable {
  const JurorVotingProcedurePageEvent();
}

final class JurorVotingProcedurePageSubscribeToVotingSessionProcedure
    extends JurorVotingProcedurePageEvent {
  final String votingSessionId;
  final String jurorId;

  const JurorVotingProcedurePageSubscribeToVotingSessionProcedure({
    required this.votingSessionId,
    required this.jurorId,
  });

  @override
  List<Object?> get props => [votingSessionId, jurorId];
}

final class JurorVotingProcedurePageSubmitVotes extends JurorVotingProcedurePageEvent {
  final String jurorId;
  final VotingSession votingSession;
  final Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap;

  const JurorVotingProcedurePageSubmitVotes({
    required this.jurorId,
    required this.votingSession,
    required this.votesPerParticipantMap,
  });

  @override
  List<Object?> get props => [
        jurorId,
        votingSession,
        votesPerParticipantMap,
      ];
}
