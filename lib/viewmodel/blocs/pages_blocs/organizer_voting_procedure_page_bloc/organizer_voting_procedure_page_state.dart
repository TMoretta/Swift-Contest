part of 'organizer_voting_procedure_page_bloc.dart';

@immutable
final class OrganizerVotingProcedurePageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingProcedurePageEvent? sourceEvent;
  final String? message;
  final VotingSessionProcedureBundle? votingSessionProcedureBundle;

  const OrganizerVotingProcedurePageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.votingSessionProcedureBundle,
  });

  OrganizerVotingProcedurePageState copyWith({
    required BlocStatus status,
    OrganizerVotingProcedurePageEvent? sourceEvent,
    String? message,
    VotingSessionProcedureBundle? votingSessionProcedureBundle,
  }) {
    return OrganizerVotingProcedurePageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      votingSessionProcedureBundle: votingSessionProcedureBundle ?? this.votingSessionProcedureBundle,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, message, votingSessionProcedureBundle];
}
