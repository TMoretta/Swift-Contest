part of 'juror_home_page_bloc.dart';

@immutable
final class JurorHomePageState extends Equatable {
  final BlocStatus status;
  final JurorHomePageEvent? sourceEvent;
  final String? message;
  final List<HomeContestBundle>? joinedContestsBundles;
  final SimpleJurorAndVotingSessionBundle? simpleJurorAndVotingSessionBundle;

  const JurorHomePageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.joinedContestsBundles,
    this.simpleJurorAndVotingSessionBundle,
  });

  JurorHomePageState copyWith({
    required BlocStatus status,
    JurorHomePageEvent? sourceEvent,
    String? message,
    List<HomeContestBundle>? joinedContestsBundles,
    SimpleJurorAndVotingSessionBundle? simpleJurorAndVotingSessionBundle,
  }) {
    return JurorHomePageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      joinedContestsBundles: joinedContestsBundles ?? this.joinedContestsBundles,
      simpleJurorAndVotingSessionBundle: simpleJurorAndVotingSessionBundle ?? this.simpleJurorAndVotingSessionBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
        joinedContestsBundles,
        simpleJurorAndVotingSessionBundle,
      ];
}
