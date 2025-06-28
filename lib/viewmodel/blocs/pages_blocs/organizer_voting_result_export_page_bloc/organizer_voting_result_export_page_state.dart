part of 'organizer_voting_result_export_page_bloc.dart';

@immutable
final class OrganizerVotingResultExportPageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingResultExportPageEvent? sourceEvent;
  final String? message;
  final VotingSessionResultBundle? votingSessionResultBundle;

  const OrganizerVotingResultExportPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.votingSessionResultBundle,
  });

  OrganizerVotingResultExportPageState copyWith({
    required BlocStatus status,
    OrganizerVotingResultExportPageEvent? sourceEvent,
    String? message,
    VotingSessionResultBundle? votingSessionResultBundle,
  }) {
    return OrganizerVotingResultExportPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      votingSessionResultBundle: votingSessionResultBundle ?? this.votingSessionResultBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
        votingSessionResultBundle,
      ];
}
