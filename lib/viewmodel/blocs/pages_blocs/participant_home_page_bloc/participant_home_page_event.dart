part of 'participant_home_page_bloc.dart';

sealed class ParticipantHomePageEvent extends Equatable {
  const ParticipantHomePageEvent();
}

final class ParticipantHomePageFetch extends ParticipantHomePageEvent {
  final String participantId;

  const ParticipantHomePageFetch({required this.participantId});

  @override
  List<Object?> get props => [participantId];
}

final class ParticipantHomePageFilterResults extends ParticipantHomePageEvent {
  final String query;

  const ParticipantHomePageFilterResults({
    required this.query,
  });

  @override
  List<Object?> get props => [query];
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
