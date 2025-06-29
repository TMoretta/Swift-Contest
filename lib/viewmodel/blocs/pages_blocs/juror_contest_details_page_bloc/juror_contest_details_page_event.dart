part of 'juror_contest_details_page_bloc.dart';

sealed class JurorContestDetailsPageEvent extends Equatable {
  const JurorContestDetailsPageEvent();
}

final class JurorContestDetailsPageInit extends JurorContestDetailsPageEvent {
  final String contestId;

  const JurorContestDetailsPageInit({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class JurorContestDetailsPageRefresh extends JurorContestDetailsPageEvent {
  final String contestId;

  const JurorContestDetailsPageRefresh({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class JurorContestDetailsPageLeaveContest extends JurorContestDetailsPageEvent {
  final String contestId;
  final String jurorId;

  const JurorContestDetailsPageLeaveContest({
    required this.contestId,
    required this.jurorId,
  });

  @override
  List<Object?> get props => [contestId, jurorId];
}
