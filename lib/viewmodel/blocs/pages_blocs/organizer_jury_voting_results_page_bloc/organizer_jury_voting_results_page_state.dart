part of 'organizer_jury_voting_results_page_bloc.dart';

@immutable
final class OrganizerJuryVotingResultsPageState extends Equatable {
  final BlocStatus status;
  final bool isInitialized;
  final OrganizerJuryVotingResultsPageEvent? sourceEvent;
  final String? message;
  // final VotingSessionJuryResultBundle? votingSessionJuryResultBundle;

  const OrganizerJuryVotingResultsPageState({
    required this.status,
    this.isInitialized = false,
    this.sourceEvent,
    this.message,
    // this.votingSessionJuryResultBundle,
  });

  OrganizerJuryVotingResultsPageState copyWith({
    required BlocStatus status,
    bool? isInitialized,
    OrganizerJuryVotingResultsPageEvent? sourceEvent,
    String? message,
    // VotingSessionJuryResultBundle? votingSessionJuryResultBundle,
  }) {
    return OrganizerJuryVotingResultsPageState(
      status: status,
      isInitialized: isInitialized ?? this.isInitialized,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      // votingSessionJuryResultBundle: votingSessionJuryResultBundle ?? this.votingSessionJuryResultBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isInitialized,
        sourceEvent,
        message,
        // votingSessionJuryResultBundle,
      ];
}
