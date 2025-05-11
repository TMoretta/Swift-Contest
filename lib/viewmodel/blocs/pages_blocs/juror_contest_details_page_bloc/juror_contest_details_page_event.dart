part of 'juror_contest_details_page_bloc.dart';

@immutable
sealed class JurorContestDetailsPageEvent extends Equatable {
  const JurorContestDetailsPageEvent();
}

final class JurorContestDetailsPageGetContestMainInfo extends JurorContestDetailsPageEvent {
  final String contestId;

  const JurorContestDetailsPageGetContestMainInfo({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class JurorContestDetailsPageGetVotingTabInfo extends JurorContestDetailsPageEvent {
  final String contestId;

  const JurorContestDetailsPageGetVotingTabInfo({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}
