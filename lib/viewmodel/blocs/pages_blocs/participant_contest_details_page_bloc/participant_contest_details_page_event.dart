part of 'participant_contest_details_page_bloc.dart';

sealed class ParticipantContestDetailsPageEvent extends Equatable {
  const ParticipantContestDetailsPageEvent();
}

final class ParticipantContestDetailsPageFetch extends ParticipantContestDetailsPageEvent {
  final String contestId;

  const ParticipantContestDetailsPageFetch({
    required this.contestId,
  });

  @override
  List<Object?> get props => [contestId];
}

final class ParticipantContestDetailsPageLeaveContest extends ParticipantContestDetailsPageEvent {
  final String contestId;

  const ParticipantContestDetailsPageLeaveContest({
    required this.contestId,
  });

  @override
  List<Object?> get props => [contestId];
}

final class ParticipantContestDetailsPageGetRankingFileUrl extends ParticipantContestDetailsPageEvent {
  final String filePath;

  const ParticipantContestDetailsPageGetRankingFileUrl({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

