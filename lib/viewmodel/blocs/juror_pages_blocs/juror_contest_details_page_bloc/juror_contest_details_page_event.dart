part of 'juror_contest_details_page_bloc.dart';

@immutable
sealed class JurorContestDetailsPageEvent {}

final class JurorContestDetailsPageGetExtendedContest
    extends JurorContestDetailsPageEvent {
  final String contestId;

  JurorContestDetailsPageGetExtendedContest({required this.contestId});
}

