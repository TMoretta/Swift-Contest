part of 'organizer_juror_voting_results_page_bloc.dart';

sealed class OrganizerJurorVotingResultsPageEvent extends Equatable {
  const OrganizerJurorVotingResultsPageEvent();
}

final class OrganizerJurorVotingResultsPageFetch extends OrganizerJurorVotingResultsPageEvent {
  final String votingSessionJurorId;

  const OrganizerJurorVotingResultsPageFetch({required this.votingSessionJurorId});

  @override
  List<Object> get props => [votingSessionJurorId];
}
