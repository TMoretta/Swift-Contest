part of 'organizer_voting_results_page_bloc.dart';

sealed class OrganizerVotingResultsPageEvent extends Equatable {
  const OrganizerVotingResultsPageEvent();
}

final class OrganizerVotingResultsPageFetch extends OrganizerVotingResultsPageEvent {
  final String votingSessionId;

  const OrganizerVotingResultsPageFetch({
    required this.votingSessionId,
  });

  @override
  List<Object?> get props => [votingSessionId];
}

final class OrganizerVotingResultsPageEditVotingSessionName
    extends OrganizerVotingResultsPageEvent {
  final String votingSessionId;
  final String name;

  const OrganizerVotingResultsPageEditVotingSessionName({
    required this.votingSessionId,
    required this.name,
  });

  @override
  List<Object?> get props => [votingSessionId, name];
}

final class OrganizerVotingResultsPageDeleteVotingSession extends OrganizerVotingResultsPageEvent {
  final String votingSessionId;

  const OrganizerVotingResultsPageDeleteVotingSession({required this.votingSessionId});

  @override
  List<Object> get props => [votingSessionId];
}
