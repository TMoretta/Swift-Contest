part of 'juror_voting_procedure_page_bloc.dart';

sealed class JurorVotingProcedurePageEvent extends Equatable {
  const JurorVotingProcedurePageEvent();
}

final class JurorVotingProcedurePageFetch
    extends JurorVotingProcedurePageEvent {
  final String votingSessionId;

  const JurorVotingProcedurePageFetch({
    required this.votingSessionId,
  });

  @override
  List<Object?> get props => [votingSessionId];
}

final class JurorVotingProcedurePageSubmitVotes extends JurorVotingProcedurePageEvent {
  final Map<VotingSessionParticipation, Map<VotingFormField, String>> votesPerParticipantMap;

  const JurorVotingProcedurePageSubmitVotes({
    required this.votesPerParticipantMap,
  });

  @override
  List<Object?> get props => [votesPerParticipantMap];
}

final class JurorVotingProcedurePageAdvanceSession extends JurorVotingProcedurePageEvent {
  const JurorVotingProcedurePageAdvanceSession();

  @override
  List<Object?> get props => [];
}