part of 'organizer_voting_results_page_bloc.dart';

final class OrganizerVotingResultsPageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingResultsPageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  // final VotingSessionResultBundle? votingSessionResultBundle;

  const OrganizerVotingResultsPageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    // this.votingSessionResultBundle,
  });

  OrganizerVotingResultsPageState copyWith({
    required BlocStatus status,
    OrganizerVotingResultsPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    // VotingSessionResultBundle? votingSessionResultBundle,
  }) {
    return OrganizerVotingResultsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      // votingSessionResultBundle: votingSessionResultBundle ?? this.votingSessionResultBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        // votingSessionResultBundle,
      ];
}
