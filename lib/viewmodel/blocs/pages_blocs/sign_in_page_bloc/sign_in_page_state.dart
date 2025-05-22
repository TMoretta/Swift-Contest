part of 'sign_in_page_bloc.dart';

@immutable
final class SignInPageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final User? user;
  final VotingSession? votingSession;
  final VotingSessionSimpleJuror? votingSessionSimpleJuror;

  const SignInPageState({
    required this.status,
    this.message,
    this.user,
    this.votingSession,
    this.votingSessionSimpleJuror,
  });

  SignInPageState copyWith({
    required BlocStatus status,
    String? message,
    User? user,
    VotingSession? votingSession,
    VotingSessionSimpleJuror? votingSessionSimpleJuror,
  }) {
    return SignInPageState(
        status: status,
        message: message,
        user: user ?? this.user,
        votingSession: votingSession ?? this.votingSession,
        votingSessionSimpleJuror: votingSessionSimpleJuror);
  }

  @override
  List<Object?> get props => [
        status,
        message,
        user,
        votingSession,
        votingSessionSimpleJuror,
      ];
}
