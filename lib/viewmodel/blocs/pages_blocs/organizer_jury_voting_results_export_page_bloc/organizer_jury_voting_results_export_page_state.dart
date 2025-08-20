part of 'organizer_jury_voting_results_export_page_bloc.dart';

@immutable
final class OrganizerJuryVotingResultsExportPageState extends Equatable {
  final BlocStatus status;
  final bool isInitialized;
  final OrganizerJuryVotingResultsExportPageEvent? sourceEvent;
  final String? message;
  final VotingSessionJuryResultBundle? votingSessionJuryResultBundle;

  const OrganizerJuryVotingResultsExportPageState({
    required this.status,
    this.isInitialized = false,
    this.sourceEvent,
    this.message,
    this.votingSessionJuryResultBundle,
  });

  OrganizerJuryVotingResultsExportPageState copyWith({
    required BlocStatus status,
    bool? isInitialized,
    OrganizerJuryVotingResultsExportPageEvent? sourceEvent,
    String? message,
    VotingSessionJuryResultBundle? votingSessionJuryResultBundle,
  }) {
    return OrganizerJuryVotingResultsExportPageState(
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