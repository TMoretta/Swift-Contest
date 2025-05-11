part of 'participant_joined_contests_bloc.dart';

sealed class ParticipantJoinedContestsEvent extends Equatable {
  const ParticipantJoinedContestsEvent();
}

final class ParticipantJoinedContestsGetJoinedContests extends ParticipantJoinedContestsEvent {
  final String participantId;

  const ParticipantJoinedContestsGetJoinedContests({required this.participantId});

  @override
  List<Object?> get props => [participantId];
}

final class ParticipantJoinedContestsClear extends ParticipantJoinedContestsEvent {
  @override
  List<Object?> get props => [];
}

