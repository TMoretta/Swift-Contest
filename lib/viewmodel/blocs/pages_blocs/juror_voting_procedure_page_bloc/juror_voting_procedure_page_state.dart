part of 'juror_voting_procedure_page_bloc.dart';

@immutable
final class JurorVotingProcedurePageState extends Equatable {
  final BlocStatus status;
  final JurorVotingProcedurePageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final VotingSessionProcedureBundle? votingSessionProcedureBundle;
  final VotingSessionJuration? ownVotingSessionJuration;

  const JurorVotingProcedurePageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.votingSessionProcedureBundle,
    this.ownVotingSessionJuration,
  });

  factory JurorVotingProcedurePageState.fromJson(Map<String, dynamic> json) {
    return JurorVotingProcedurePageState(
      status: BlocStatus.values.byName(json['status']),
      isInitialized: json['is_initialized'] as bool,
      votingSessionProcedureBundle: (json['voting_session_procedure_bundle'] != null)
          ? VotingSessionProcedureBundle.fromJson(json['voting_session_procedure_bundle'])
          : null,
      ownVotingSessionJuration: (json['own_voting_session_juration'] != null)
          ? VotingSessionJuration.fromJson(json['own_voting_session_juration'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'is_initialized': isInitialized,
      'voting_session_procedure_bundle': votingSessionProcedureBundle?.toJson(),
      'own_voting_session_juration': ownVotingSessionJuration?.toJson(),
    };
  }

  JurorVotingProcedurePageState copyWith({
    required BlocStatus status,
    JurorVotingProcedurePageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    VotingSessionProcedureBundle? votingSessionProcedureBundle,
    VotingSessionJuration? ownVotingSessionJuration,
  }) {
    return JurorVotingProcedurePageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      votingSessionProcedureBundle:
          votingSessionProcedureBundle ?? this.votingSessionProcedureBundle,
      ownVotingSessionJuration: ownVotingSessionJuration ?? this.ownVotingSessionJuration,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        votingSessionProcedureBundle,
        ownVotingSessionJuration,
      ];
}
