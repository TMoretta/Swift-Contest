part of 'organizer_voting_result_details_page_bloc.dart';

sealed class OrganizerVotingResultDetailsPageEvent extends Equatable {
  const OrganizerVotingResultDetailsPageEvent();
}

final class OrganizerVotingResultDetailsPageGetResultInfo
    extends OrganizerVotingResultDetailsPageEvent {
  final ContestDetailsBundle contestDetailsBundle;
  final VotingSession votingSession;

  const OrganizerVotingResultDetailsPageGetResultInfo({
    required this.contestDetailsBundle,
    required this.votingSession,
  });

  @override
  List<Object?> get props => [contestDetailsBundle, votingSession];
}
