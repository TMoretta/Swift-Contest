part of 'organizer_voting_result_details_page_bloc.dart';

final class OrganizerVotingResultDetailsPageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingResultDetailsPageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final VotingSessionResultBundle? votingSessionResultBundle;

  const OrganizerVotingResultDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.votingSessionResultBundle,
  });

  OrganizerVotingResultDetailsPageState copyWith({
    required BlocStatus status,
    OrganizerVotingResultDetailsPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    VotingSessionResultBundle? votingSessionResultBundle,
  }) {
    return OrganizerVotingResultDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      votingSessionResultBundle: votingSessionResultBundle ?? this.votingSessionResultBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        votingSessionResultBundle,
      ];
}
