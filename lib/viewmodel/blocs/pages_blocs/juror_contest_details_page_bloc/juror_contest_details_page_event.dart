part of 'juror_contest_details_page_bloc.dart';

sealed class JurorContestDetailsPageEvent extends Equatable {
  const JurorContestDetailsPageEvent();
}

final class JurorContestDetailsPageFetch extends JurorContestDetailsPageEvent {
  final String contestId;

  const JurorContestDetailsPageFetch({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class JurorContestDetailsPageLeaveContest extends JurorContestDetailsPageEvent {
  final String contestId;

  const JurorContestDetailsPageLeaveContest({
    required this.contestId,
  });

  @override
  List<Object?> get props => [contestId];
}

final class JurorContestDetailsPageGetRankingFileUrl extends JurorContestDetailsPageEvent {
  final String filePath;

  const JurorContestDetailsPageGetRankingFileUrl({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

final class JurorContestDetailsPageCheckVotingLocation extends JurorContestDetailsPageEvent {
  @override
  List<Object?> get props => [];
}

