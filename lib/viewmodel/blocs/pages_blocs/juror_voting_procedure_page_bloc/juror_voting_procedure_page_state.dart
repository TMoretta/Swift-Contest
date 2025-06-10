part of 'juror_voting_procedure_page_bloc.dart';

@immutable
final class JurorVotingProcedurePageState extends Equatable {
  final BlocStatus status;
  final JurorVotingProcedurePageEvent? sourceEvent;
  // final BlocStatusFailureType? failureType;
  final String? message;
  final JurorVotingSessionBundle? votingSessionBundle;

  const JurorVotingProcedurePageState({
    required this.status,
    this.sourceEvent,
    // this.failureType,
    this.message,
    this.votingSessionBundle,
  });

  JurorVotingProcedurePageState copyWith({
    required BlocStatus status,
    JurorVotingProcedurePageEvent? sourceEvent,
    // BlocStatusFailureType? failureType,
    String? message,
    JurorVotingSessionBundle? votingSessionBundle,
  }) {
    return JurorVotingProcedurePageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      // failureType: failureType,
      message: message,
      votingSessionBundle: votingSessionBundle ?? this.votingSessionBundle,
    );
  }

  @override
  List<Object?> get props => [
    status,
    sourceEvent,
    // failureType,
    message,
    votingSessionBundle,
  ];
}
