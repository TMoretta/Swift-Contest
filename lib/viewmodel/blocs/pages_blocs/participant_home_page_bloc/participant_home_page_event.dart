part of 'participant_home_page_bloc.dart';

@immutable
sealed class ParticipantHomePageEvent extends Equatable {
  const ParticipantHomePageEvent();
}

// final class ParticipantHomePageGetJoinedContestsExtended extends ParticipantHomePageEvent {
//   final String participantId;
//
//   const ParticipantHomePageGetJoinedContestsExtended({required this.participantId});
//
//   @override
//   List<Object?> get props => [participantId];
// }

final class ParticipantHomePageJoinContest extends ParticipantHomePageEvent {
  final String participantId;
  final String contestToken;
  final String participantToken;

  const ParticipantHomePageJoinContest({required this.participantId, required this.contestToken, required this.participantToken,});

  @override
  List<Object?> get props => [participantId, contestToken,participantToken];
}

