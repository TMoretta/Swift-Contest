part of 'participant_home_page_bloc.dart';

sealed class ParticipantHomePageEvent extends Equatable {
  const ParticipantHomePageEvent();
}

final class ParticipantHomePageFetch extends ParticipantHomePageEvent {
  @override
  List<Object?> get props => [];
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
  final String token;

  const ParticipantHomePageJoinContest({
    required this.token,
  });

  @override
  List<Object?> get props => [token];
}
