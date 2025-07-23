part of 'organizer_voting_result_export_page_bloc.dart';

sealed class OrganizerVotingResultExportPageEvent extends Equatable {
  const OrganizerVotingResultExportPageEvent();
}

final class OrganizerVotingResultExportPageFetch extends OrganizerVotingResultExportPageEvent {
  final String votingSessionId;

  const OrganizerVotingResultExportPageFetch({
    required this.votingSessionId,
  });

  @override
  List<Object?> get props => [votingSessionId];
}
