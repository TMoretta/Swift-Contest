part of 'participant_contest_details_page_bloc.dart';

sealed class ParticipantContestDetailsPageEvent extends Equatable {
  const ParticipantContestDetailsPageEvent();
}

final class ParticipantContestDetailsPageFetch extends ParticipantContestDetailsPageEvent {
  final String contestId;
  final String participantId;

  const ParticipantContestDetailsPageFetch({
    required this.contestId,
    required this.participantId,
  });

  @override
  List<Object?> get props => [contestId, participantId];
}

final class ParticipantContestDetailsPageLeaveContest extends ParticipantContestDetailsPageEvent {
  final String contestId;
  final String participantId;

  const ParticipantContestDetailsPageLeaveContest({
    required this.contestId,
    required this.participantId,
  });

  @override
  List<Object?> get props => [contestId, participantId];
}
