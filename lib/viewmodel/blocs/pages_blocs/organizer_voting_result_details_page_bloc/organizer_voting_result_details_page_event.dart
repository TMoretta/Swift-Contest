part of 'organizer_voting_result_details_page_bloc.dart';

sealed class OrganizerVotingResultDetailsPageEvent extends Equatable {
  const OrganizerVotingResultDetailsPageEvent();
}

final class OrganizerVotingResultDetailsPageInit extends OrganizerVotingResultDetailsPageEvent {
  final String votingSessionId;

  const OrganizerVotingResultDetailsPageInit({
    required this.votingSessionId,
  });

  @override
  List<Object?> get props => [votingSessionId];
}

final class OrganizerVotingResultDetailsPageRefresh extends OrganizerVotingResultDetailsPageEvent {
  final String votingSessionId;

  const OrganizerVotingResultDetailsPageRefresh({
    required this.votingSessionId,
  });

  @override
  List<Object?> get props => [votingSessionId];
}

final class OrganizerVotingResultDetailsPageEditVotingSessionName
    extends OrganizerVotingResultDetailsPageEvent {
  final String votingSessionId;
  final String name;

  const OrganizerVotingResultDetailsPageEditVotingSessionName({
    required this.votingSessionId,
    required this.name,
  });

  @override
  List<Object?> get props => [votingSessionId, name];
}
