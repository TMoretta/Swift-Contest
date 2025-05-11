part of 'participant_contest_details_page_bloc.dart';

@immutable
sealed class ParticipantContestDetailsPageEvent {}

final class ParticipantContestDetailsPageGetOwnWork extends ParticipantContestDetailsPageEvent {
  final String contestId;
  final String participantId;

  ParticipantContestDetailsPageGetOwnWork({required this.contestId, required this.participantId});
}

final class ParticipantContestDetailsPageGetContestMainInfo
    extends ParticipantContestDetailsPageEvent {
  final String contestId;

  ParticipantContestDetailsPageGetContestMainInfo({required this.contestId});
}
