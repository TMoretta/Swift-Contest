part of 'organizer_voting_results_page_bloc.dart';

sealed class OrganizerVotingResultsPageEvent extends Equatable {
  const OrganizerVotingResultsPageEvent();
}

final class OrganizerVotingResultsPageGetResultsInfo extends OrganizerVotingResultsPageEvent {
  final String votingSessionId;

  const OrganizerVotingResultsPageGetResultsInfo({ required this.votingSessionId});

  @override
  List<Object?> get props => [votingSessionId];
}
