part of 'organizer_voting_result_export_page_bloc.dart';

sealed class OrganizerVotingResultExportPageEvent extends Equatable {
  const OrganizerVotingResultExportPageEvent();
}

final class OrganizerVotingResultExportPageInit extends OrganizerVotingResultExportPageEvent {
  final String votingSessionId;

  const OrganizerVotingResultExportPageInit({
    required this.votingSessionId,
  });

  @override
  List<Object?> get props => [votingSessionId];
}

final class OrganizerVotingResultExportPageRefresh extends OrganizerVotingResultExportPageEvent {
  final String votingSessionId;

  const OrganizerVotingResultExportPageRefresh({
    required this.votingSessionId,
  });

  @override
  List<Object?> get props => [votingSessionId];
}
