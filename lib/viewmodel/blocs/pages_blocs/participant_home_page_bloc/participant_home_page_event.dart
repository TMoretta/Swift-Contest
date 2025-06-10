part of 'participant_home_page_bloc.dart';

sealed class ParticipantHomePageEvent extends Equatable {
  const ParticipantHomePageEvent();
}

final class ParticipantHomePageGetJoinedContests extends ParticipantHomePageEvent {
  final String participantId;

  const ParticipantHomePageGetJoinedContests({required this.participantId});

  @override
  List<Object?> get props => [participantId];
}

final class ParticipantHomePageJoinContest extends ParticipantHomePageEvent {
  final String participantId;
  final String token;

  const ParticipantHomePageJoinContest({
    required this.participantId,
    required this.token,
  });

  @override
  List<Object?> get props => [participantId, token];
}
