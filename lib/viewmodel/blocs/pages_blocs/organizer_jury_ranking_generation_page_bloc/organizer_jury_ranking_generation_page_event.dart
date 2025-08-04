part of 'organizer_jury_ranking_generation_page_bloc.dart';

sealed class OrganizerJuryRankingGenerationPageEvent extends Equatable {
  const OrganizerJuryRankingGenerationPageEvent();
}

final class OrganizerJuryRankingGenerationPageFetch extends OrganizerJuryRankingGenerationPageEvent {
  final String votingSessionJuryId;

  const OrganizerJuryRankingGenerationPageFetch({required this.votingSessionJuryId});

  @override
  List<Object> get props => [votingSessionJuryId];
}
