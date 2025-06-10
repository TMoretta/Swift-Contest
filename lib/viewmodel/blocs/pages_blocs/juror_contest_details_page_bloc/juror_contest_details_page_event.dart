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

// final class JurorContestDetailsPageGetRemainingInfo extends JurorContestDetailsPageEvent {
//   final HomeContestBundle homeContestBundle;
//
//   const JurorContestDetailsPageGetRemainingInfo({required this.homeContestBundle});
//
//   @override
//   List<Object?> get props => [homeContestBundle];
// }
