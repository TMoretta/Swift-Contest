part of 'organizer_voting_procedure_page_bloc.dart';

@immutable
final class OrganizerVotingProcedurePageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingProcedurePageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final OrganizerVotingSessionProcedureBundle? votingSessionProcedureBundle;

  const OrganizerVotingProcedurePageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.votingSessionProcedureBundle,
  });

  factory OrganizerVotingProcedurePageState.fromJson(Map<String, dynamic> json) {
    return OrganizerVotingProcedurePageState(
      status: BlocStatus.values.byName(json['status']),
      isInitialized: json['is_initialized'] as bool,
      votingSessionProcedureBundle: (json['voting_session_procedure_bundle'] != null)
          ? OrganizerVotingSessionProcedureBundle.fromJson(json['voting_session_procedure_bundle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'is_initialized': isInitialized,
      'voting_session_procedure_bundle': votingSessionProcedureBundle?.toJson(),
    };
  }

  OrganizerVotingProcedurePageState copyWith({
    required BlocStatus status,
    OrganizerVotingProcedurePageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    OrganizerVotingSessionProcedureBundle? votingSessionProcedureBundle,
  }) {
    return OrganizerVotingProcedurePageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      votingSessionProcedureBundle: votingSessionProcedureBundle ?? this.votingSessionProcedureBundle,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, isInitialized, message, votingSessionProcedureBundle];
}
