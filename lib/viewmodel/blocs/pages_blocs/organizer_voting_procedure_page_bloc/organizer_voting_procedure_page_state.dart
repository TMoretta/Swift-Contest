part of 'organizer_voting_procedure_page_bloc.dart';

@immutable
final class OrganizerVotingProcedurePageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingProcedurePageEvent? sourceEvent;
  final String? message;
  final VotingSessionBundle? votingSessionBundle;

  const OrganizerVotingProcedurePageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.votingSessionBundle,
  });

  OrganizerVotingProcedurePageState copyWith({
    required BlocStatus status,
    OrganizerVotingProcedurePageEvent? sourceEvent,
    String? message,
    VotingSessionBundle? votingSessionBundle,
  }) {
    return OrganizerVotingProcedurePageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      votingSessionBundle: votingSessionBundle ?? this.votingSessionBundle,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, message, votingSessionBundle];
}
