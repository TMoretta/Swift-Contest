part of 'organizer_voting_procedure_page_bloc.dart';

sealed class OrganizerVotingProcedurePageEvent extends Equatable {
  const OrganizerVotingProcedurePageEvent();
}

final class OrganizerVotingProcedurePageStartVotingSessionProcedure extends OrganizerVotingProcedurePageEvent {
  final String votingSessionId;

  const OrganizerVotingProcedurePageStartVotingSessionProcedure({required this.votingSessionId});

  @override
  List<Object?> get props => [votingSessionId];
}

final class OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure extends OrganizerVotingProcedurePageEvent {
  final OrganizerVotingSessionBundle votingSessionBundle;

  const OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure({
    required this.votingSessionBundle,
  });

  @override
  List<Object?> get props => [votingSessionBundle];
}

final class OrganizerVotingProcedurePageCancelVotingSessionProcedure
    extends OrganizerVotingProcedurePageEvent {
  final String votingSessionId;

  const OrganizerVotingProcedurePageCancelVotingSessionProcedure({
    required this.votingSessionId,
  });

  @override
  List<Object?> get props => [votingSessionId];
}

final class OrganizerVotingProcedurePageEndVotingSessionProcedure extends OrganizerVotingProcedurePageEvent {
  final String votingSessionId;

  const OrganizerVotingProcedurePageEndVotingSessionProcedure({
    required this.votingSessionId,
  });

  @override
  List<Object?> get props => [votingSessionId];
}
