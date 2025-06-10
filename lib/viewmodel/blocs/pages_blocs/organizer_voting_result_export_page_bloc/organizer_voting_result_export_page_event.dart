part of 'organizer_voting_result_export_page_bloc.dart';

sealed class OrganizerVotingResultExportPageEvent extends Equatable {
  const OrganizerVotingResultExportPageEvent();
}

final class OrganizerVotingResultExportPageGetResultInfo extends OrganizerVotingResultExportPageEvent {
  final OrganizerVotingSessionBundle votingSessionBundle;

  const OrganizerVotingResultExportPageGetResultInfo({ required this.votingSessionBundle});

  @override
  List<Object?> get props => [votingSessionBundle];
}

