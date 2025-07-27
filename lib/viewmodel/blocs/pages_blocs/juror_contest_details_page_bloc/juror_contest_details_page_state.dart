part of 'juror_contest_details_page_bloc.dart';

@immutable
final class JurorContestDetailsPageState extends Equatable {
  final BlocStatus status;
  final JurorContestDetailsPageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final ContestDetailsBundle? contestDetailsBundle;
  // final VotingSessionProcedureBundle? votingSessionProcedureBundle;

  const JurorContestDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.contestDetailsBundle,
    // this.votingSessionProcedureBundle,
  });

  JurorContestDetailsPageState copyWith({
    required BlocStatus status,
    JurorContestDetailsPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    ContestDetailsBundle? contestDetailsBundle,
    // VotingSessionProcedureBundle? votingSessionProcedureBundle,
  }) {
    return JurorContestDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      contestDetailsBundle: contestDetailsBundle ?? this.contestDetailsBundle,
      // votingSessionProcedureBundle: votingSessionProcedureBundle ?? this.votingSessionProcedureBundle,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, message, contestDetailsBundle];
}
