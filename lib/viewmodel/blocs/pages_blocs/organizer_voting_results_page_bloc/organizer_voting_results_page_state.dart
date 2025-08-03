part of 'organizer_voting_results_page_bloc.dart';

final class OrganizerVotingResultsPageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingResultsPageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final VotingSessionResultBundle? votingSessionResultBundle;

  const OrganizerVotingResultsPageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.votingSessionResultBundle,
  });

  factory OrganizerVotingResultsPageState.fromJson(Map<String, dynamic> json) {
    return OrganizerVotingResultsPageState(
      status: BlocStatus.values.byName(json['status']),
      isInitialized: json['is_initialized'] as bool,
      votingSessionResultBundle: (json['voting_session_result_bundle'] != null)
          ? VotingSessionResultBundle.fromJson(json['voting_session_result_bundle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'is_initialized': isInitialized,
      'voting_session_result_bundle': votingSessionResultBundle?.toJson(),
    };
  }

  OrganizerVotingResultsPageState copyWith({
    required BlocStatus status,
    OrganizerVotingResultsPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    VotingSessionResultBundle? votingSessionResultBundle,
  }) {
    return OrganizerVotingResultsPageState(
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
