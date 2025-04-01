part of 'juror_contest_details_page_bloc.dart';

@immutable
sealed class JurorContestDetailsPageEvent extends Equatable {
  const JurorContestDetailsPageEvent();
}

final class JurorContestDetailsPageGetExtendedContest extends JurorContestDetailsPageEvent {
  final String contestId;

  const JurorContestDetailsPageGetExtendedContest({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}
