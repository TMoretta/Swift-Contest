part of 'juror_home_page_bloc.dart';

@immutable
final class JurorHomePageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final Juration? jurationJoin;
  final String? contestId;
  final VotingSession? votingSession;
  final VotingSessionSimpleJuror? votingSessionSimpleJuror;

  const JurorHomePageState({
    required this.status,
    this.message,
    this.jurationJoin,
    this.contestId,
    this.votingSession,
    this.votingSessionSimpleJuror,
  });

  JurorHomePageState copyWith({
    required BlocStatus status,
    String? message,
    Juration? jurationJoin,
    String? contestId,
    VotingSession? votingSession,
    VotingSessionSimpleJuror? votingSessionSimpleJuror,
  }) {
    return JurorHomePageState(
      status: status,
      message: message,
      jurationJoin: jurationJoin ?? this.jurationJoin,
      contestId: contestId ?? this.contestId,
      votingSession: votingSession ?? this.votingSession,
      votingSessionSimpleJuror:
          votingSessionSimpleJuror ?? this.votingSessionSimpleJuror,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        jurationJoin,
        contestId,
        votingSession,
        votingSessionSimpleJuror,
      ];
}
