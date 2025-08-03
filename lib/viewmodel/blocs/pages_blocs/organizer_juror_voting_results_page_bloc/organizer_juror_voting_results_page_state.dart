part of 'organizer_juror_voting_results_page_bloc.dart';

@immutable
final class OrganizerJurorVotingResultsPageState extends Equatable {
  final BlocStatus status;
  final bool isInitialized;
  final OrganizerJurorVotingResultsPageEvent? sourceEvent;
  final String? message;
  final VotingSessionJurorResultBundle? votingSessionJurorResultBundle;

  const OrganizerJurorVotingResultsPageState({
    required this.status,
    this.isInitialized = false,
    this.sourceEvent,
    this.message,
    this.votingSessionJurorResultBundle,
  });

  OrganizerJurorVotingResultsPageState copyWith({
    required BlocStatus status,
    bool? isInitialized,
    OrganizerJurorVotingResultsPageEvent? sourceEvent,
    String? message,
    VotingSessionJurorResultBundle? votingSessionJurorResultBundle,
  }) {
    return OrganizerJurorVotingResultsPageState(
      status: status,
      isInitialized: isInitialized ?? this.isInitialized,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      votingSessionJurorResultBundle:
          votingSessionJurorResultBundle ?? this.votingSessionJurorResultBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isInitialized,
        sourceEvent,
        message,
        votingSessionJurorResultBundle,
      ];
}
