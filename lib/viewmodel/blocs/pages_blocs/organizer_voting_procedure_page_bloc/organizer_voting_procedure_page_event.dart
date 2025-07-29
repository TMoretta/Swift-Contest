part of 'organizer_voting_procedure_page_bloc.dart';

sealed class OrganizerVotingProcedurePageEvent extends Equatable {
  const OrganizerVotingProcedurePageEvent();
}

final class OrganizerVotingProcedurePageFetch extends OrganizerVotingProcedurePageEvent {
  final String votingSessionId;

  const OrganizerVotingProcedurePageFetch({
    required this.votingSessionId,
  });

  @override
  List<Object?> get props => [votingSessionId];
}

final class OrganizerVotingProcedurePageStartVotingSession extends OrganizerVotingProcedurePageEvent {
  final String votingSessionId;

  const OrganizerVotingProcedurePageStartVotingSession({required this.votingSessionId});

  @override
  List<Object?> get props => [votingSessionId];
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

// final class OrganizerVotingProcedurePageAdvanceSession extends OrganizerVotingProcedurePageEvent {
//   const OrganizerVotingProcedurePageAdvanceSession();
//
//   @override
//   List<Object?> get props => [];
// }
