part of 'participant_home_page_bloc.dart';

@immutable
sealed class ParticipantHomePageEvent {}

final class ParticipantHomePageGetJoinedContestsExtended extends ParticipantHomePageEvent {
  final String participantId;

  ParticipantHomePageGetJoinedContestsExtended({required this.participantId});
}

final class ParticipantHomePageJoinContest extends ParticipantHomePageEvent {
  final String participantId;
  final String contestToken;
  final String participantToken;

  ParticipantHomePageJoinContest({required this.participantId, required this.contestToken, required this.participantToken,});
}

