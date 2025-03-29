part of 'juror_home_page_bloc.dart';

@immutable
sealed class JurorHomePageEvent {}

final class JurorHomePageGetJoinedContestsExtended extends JurorHomePageEvent {
  final String jurorId;

  JurorHomePageGetJoinedContestsExtended({required this.jurorId});
}

final class JurorHomePageJoinContest extends JurorHomePageEvent {
  final String jurorId;
  final String contestToken;
  final String jurorToken;

  JurorHomePageJoinContest({
    required this.jurorId,
    required this.contestToken,
    required this.jurorToken,
  });
}
