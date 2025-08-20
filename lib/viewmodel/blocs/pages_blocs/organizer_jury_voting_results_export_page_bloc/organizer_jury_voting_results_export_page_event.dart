part of 'organizer_jury_voting_results_export_page_bloc.dart';

sealed class OrganizerJuryVotingResultsExportPageEvent extends Equatable {
  const OrganizerJuryVotingResultsExportPageEvent();
}

final class OrganizerJuryVotingResultsExportPageFetch extends OrganizerJuryVotingResultsExportPageEvent {
  final String votingSessionJuryId;

  const OrganizerJuryVotingResultsExportPageFetch({required this.votingSessionJuryId});

  @override
  List<Object> get props => [votingSessionJuryId];
}
