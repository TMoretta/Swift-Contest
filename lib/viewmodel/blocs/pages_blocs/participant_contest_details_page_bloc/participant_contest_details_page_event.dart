part of 'participant_contest_details_page_bloc.dart';

sealed class ParticipantContestDetailsPageEvent extends Equatable {
  const ParticipantContestDetailsPageEvent();
}

final class ParticipantContestDetailsPageInit extends ParticipantContestDetailsPageEvent {
  final String contestId;
  final String participantId;

  const ParticipantContestDetailsPageInit({required this.contestId, required this.participantId,});

  @override
  List<Object?> get props => [contestId, participantId];
}

// final class ParticipantContestDetailsPageGetRemainingInfo extends ParticipantContestDetailsPageEvent {
//   final HomeContestBundle homeContestBundle;
//   final String participantId;
//
//   const ParticipantContestDetailsPageGetRemainingInfo({required this.homeContestBundle, required this.participantId,});
//
//   @override
//   List<Object?> get props => [homeContestBundle, participantId];
// }

