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

final class JurorVotingProcedurePageResubscribeToVotingSessionProcedure
    extends JurorVotingProcedurePageEvent {
  final String votingSessionId;
  final String jurorId;

  const JurorVotingProcedurePageResubscribeToVotingSessionProcedure({
    required this.votingSessionId,
    required this.jurorId,
  });

  @override
  List<Object?> get props => [votingSessionId, jurorId];
}

final class JurorVotingProcedurePageSubmitVotes extends JurorVotingProcedurePageEvent {
  final String jurorId;
  final VotingSession votingSession;
  final Place? geoResPlace;
  final Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap;

  const JurorVotingProcedurePageSubmitVotes({
    required this.jurorId,
    required this.votingSession,
     this.geoResPlace,
    required this.votesPerParticipantMap,
  });

  @override
  List<Object?> get props => [
        jurorId,
        votingSession,
        geoResPlace,
        votesPerParticipantMap,
      ];
}
