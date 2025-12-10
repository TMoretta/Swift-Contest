part of 'sign_in_page_bloc.dart';

@immutable
final class SignInPageState extends Equatable {
  final BlocStatus status;
  final SignInPageEvent? sourceEvent;
  final String? message;
  final VotingSession? votingSession;

  const SignInPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.votingSession,
  });


factory SignInPageState.fromJson(Map<String, dynamic> json) {
    return SignInPageState(
      status: BlocStatus.values.byName(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
    };
  }

  SignInPageState copyWith({
    required BlocStatus status,
    SignInPageEvent? sourceEvent,
    String? message,
    VotingSession? votingSession,
  }) {
    return SignInPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      votingSession: votingSession ?? this.votingSession,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
        votingSession,
      ];
}
