part of 'juror_contest_details_page_bloc.dart';

@immutable
final class JurorContestDetailsPageState extends Equatable {
  final BlocStatus status;
  final JurorContestDetailsPageEvent? sourceEvent;
  final String? message;
  final ContestDetailsBundle? contestDetailsBundle;
  final VotingSessionProcedureBundle? votingSessionProcedureBundle;

  const JurorContestDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.contestDetailsBundle,
    this.votingSessionProcedureBundle,
  });

  JurorContestDetailsPageState copyWith({
    required BlocStatus status,
    JurorContestDetailsPageEvent? sourceEvent,
    String? message,
    ContestDetailsBundle? contestDetailsBundle,
    VotingSessionProcedureBundle? votingSessionProcedureBundle,
  }) {
    return JurorContestDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      contestDetailsBundle: contestDetailsBundle ?? this.contestDetailsBundle,
      votingSessionProcedureBundle: votingSessionProcedureBundle ?? this.votingSessionProcedureBundle,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, message, contestDetailsBundle, votingSessionProcedureBundle];
}
