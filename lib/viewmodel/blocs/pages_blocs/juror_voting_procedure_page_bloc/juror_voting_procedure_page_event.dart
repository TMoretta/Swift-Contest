part of 'juror_voting_procedure_page_bloc.dart';

sealed class JurorVotingProcedurePageEvent extends Equatable {
  const JurorVotingProcedurePageEvent();
}

final class JurorVotingProcedurePageSubscribeToVotingSessionProcedure
    extends JurorVotingProcedurePageEvent {
  final ContestDetailsBundle contestDetailsBundle;
  final String jurorId;

  const JurorVotingProcedurePageSubscribeToVotingSessionProcedure({
    required this.contestDetailsBundle,
    required this.jurorId,
  });

  @override
  List<Object?> get props => [contestDetailsBundle, jurorId,];
}

final class JurorVotingProcedurePageSubmitVotes
    extends JurorVotingProcedurePageEvent {
  final String jurorId;
  final VotingSession votingSession;
  final String contestId;
  final Map<VotingSessionParticipation, Map<VotingFormField, int>>
  votesPerParticipantMap;

  const JurorVotingProcedurePageSubmitVotes({
    required this.jurorId,
    required this.votingSession,
    required this.contestId,
    required this.votesPerParticipantMap,
  });

  @override
  List<Object?> get props => [
    jurorId,
    votingSession,
    contestId,
    votesPerParticipantMap,
  ];
}
