part of 'organizer_jury_voting_results_page_bloc.dart';

sealed class OrganizerJuryVotingResultsPageEvent extends Equatable {
  const OrganizerJuryVotingResultsPageEvent();
}

final class OrganizerJuryVotingResultsPageFetch extends OrganizerJuryVotingResultsPageEvent {
  final String votingSessionJuryId;

  const OrganizerJuryVotingResultsPageFetch({
    required this.votingSessionJuryId,
  });

  @override
  List<Object?> get props => [
        votingSessionJuryId,
      ];
}
