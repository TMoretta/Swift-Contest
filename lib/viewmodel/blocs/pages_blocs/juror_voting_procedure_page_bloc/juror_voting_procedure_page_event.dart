part of 'juror_voting_procedure_page_bloc.dart';

sealed class JurorVotingProcedurePageEvent extends Equatable {
  const JurorVotingProcedurePageEvent();
}

final class JurorVotingProcedurePageSubscribeToVotingSessionProcedure
    extends JurorVotingProcedurePageEvent {
  final String contestId;
  final String jurorId;

  const JurorVotingProcedurePageSubscribeToVotingSessionProcedure({
    required this.contestId,
    required this.jurorId,
  });

  @override
  List<Object?> get props => [contestId, jurorId];
}

final class JurorVotingProcedurePageSubmitVotes extends JurorVotingProcedurePageEvent {
  final String jurorId;
  final String votingSessionId;
  final Map<VotingSessionParticipant, Map<VotingFormField, String>> votesPerParticipantMap;

  const JurorVotingProcedurePageSubmitVotes({
    required this.jurorId,
    required this.votingSessionId,
    required this.votesPerParticipantMap,
  });

  @override
  List<Object?> get props => [
    jurorId,
    votingSessionId,
    votesPerParticipantMap,
      ];
}

final class JurorVotingProcedurePageJoinVotingSessionProcedure
    extends JurorVotingProcedurePageEvent {
  final String contestId;

  const JurorVotingProcedurePageJoinVotingSessionProcedure({
    required this.contestId,
  });

  @override
  List<Object?> get props => [contestId];
}

final class JurorVotingProcedurePageExitVotingSessionProcedure
    extends JurorVotingProcedurePageEvent {
  final String votingSessionProcedureId;

  const JurorVotingProcedurePageExitVotingSessionProcedure(
      {required this.votingSessionProcedureId});

  @override
  List<Object?> get props => [votingSessionProcedureId];
}
