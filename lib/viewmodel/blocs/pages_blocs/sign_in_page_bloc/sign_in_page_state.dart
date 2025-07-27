part of 'sign_in_page_bloc.dart';

@immutable
final class SignInPageState extends Equatable {
  final BlocStatus status;
  final SignInPageEvent? sourceEvent;
  final String? message;

  // final SimpleJurorAndVotingSessionBundle? simpleJurorAndVotingSessionBundle;

  const SignInPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    // this.simpleJurorAndVotingSessionBundle,
  });

  SignInPageState copyWith({
    required BlocStatus status,
    SignInPageEvent? sourceEvent,
    String? message,
    // SimpleJurorAndVotingSessionBundle? simpleJurorAndVotingSessionBundle,
  }) {
    return SignInPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      // simpleJurorAndVotingSessionBundle: simpleJurorAndVotingSessionBundle ?? this.simpleJurorAndVotingSessionBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
        // simpleJurorAndVotingSessionBundle,
      ];
}
