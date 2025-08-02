part of 'juror_voting_procedure_page_bloc.dart';

@immutable
final class JurorVotingProcedurePageState extends Equatable {
  final BlocStatus status;
  final JurorVotingProcedurePageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final JurorVotingSessionProcedureBundle? votingSessionProcedureBundle;

  const JurorVotingProcedurePageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.votingSessionProcedureBundle,
  });

  factory JurorVotingProcedurePageState.fromJson(Map<String, dynamic> json) {
    return JurorVotingProcedurePageState(
      status: BlocStatus.values.byName(json['status']),
      isInitialized: json['is_initialized'] as bool,
      votingSessionProcedureBundle: (json['voting_session_procedure_bundle'] != null)
          ? JurorVotingSessionProcedureBundle.fromJson(json['voting_session_procedure_bundle'])
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

  JurorVotingProcedurePageState copyWith({
    required BlocStatus status,
    JurorVotingProcedurePageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    JurorVotingSessionProcedureBundle? votingSessionProcedureBundle,
    VotingSessionJuror? ownVotingSessionJuration,
  }) {
    return JurorVotingProcedurePageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      votingSessionProcedureBundle:
          votingSessionProcedureBundle ?? this.votingSessionProcedureBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        votingSessionProcedureBundle,
      ];
}
