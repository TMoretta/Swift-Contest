part of 'organizer_voting_procedure_page_bloc.dart';

sealed class OrganizerVotingProcedurePageEvent extends Equatable {
  const OrganizerVotingProcedurePageEvent();
}

final class OrganizerVotingProcedurePageGetVotingSession extends OrganizerVotingProcedurePageEvent {
  final String contestId;

  const OrganizerVotingProcedurePageGetVotingSession({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class OrganizerVotingProcedurePageStartVotingSessionProcedure
    extends OrganizerVotingProcedurePageEvent {
  final String contestId;

  const OrganizerVotingProcedurePageStartVotingSessionProcedure({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure
    extends OrganizerVotingProcedurePageEvent {
  final String contestId;

  const OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure({
    required this.contestId,
  });

  @override
  List<Object?> get props => [contestId];
}

final class OrganizerVotingProcedurePageCancelVotingSessionProcedure
    extends OrganizerVotingProcedurePageEvent {
  final String votingSessionProcedureId;

  const OrganizerVotingProcedurePageCancelVotingSessionProcedure({
    required this.votingSessionProcedureId,
  });

  @override
  List<Object?> get props => [votingSessionProcedureId];
}
