part of 'organizer_jury_ranking_generation_page_bloc.dart';

@immutable
final class OrganizerJuryRankingGenerationPageState extends Equatable {
  final BlocStatus status;
  final bool isInitialized;
  final OrganizerJuryRankingGenerationPageEvent? sourceEvent;
  final String? message;
  final VotingSessionJuryResultBundle? votingSessionJuryResultBundle;

  const OrganizerJuryRankingGenerationPageState({
    required this.status,
    this.isInitialized = false,
    this.sourceEvent,
    this.message,
    this.votingSessionJuryResultBundle,
  });

  OrganizerJuryRankingGenerationPageState copyWith({
    required BlocStatus status,
    bool? isInitialized,
    OrganizerJuryRankingGenerationPageEvent? sourceEvent,
    String? message,
    VotingSessionJuryResultBundle? votingSessionJuryResultBundle,
  }) {
    return OrganizerJuryRankingGenerationPageState(
      status: status,
      isInitialized: isInitialized ?? this.isInitialized,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      votingSessionJuryResultBundle:
          votingSessionJuryResultBundle ?? this.votingSessionJuryResultBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isInitialized,
        sourceEvent,
        message,
        votingSessionJuryResultBundle,
      ];
}
