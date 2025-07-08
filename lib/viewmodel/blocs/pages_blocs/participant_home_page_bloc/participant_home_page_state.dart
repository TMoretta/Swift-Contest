part of 'participant_home_page_bloc.dart';

@immutable
final class ParticipantHomePageState extends Equatable {
  final BlocStatus status;
  final ParticipantHomePageEvent? sourceEvent;
  final String? message;
  final List<HomeContestBundle>? joinedContestsBundles;
  final List<HomeContestBundle>? filteredContestsBundles;

  const ParticipantHomePageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.joinedContestsBundles,
    this.filteredContestsBundles,
  });

  ParticipantHomePageState copyWith({
    required BlocStatus status,
    ParticipantHomePageEvent? sourceEvent,
    String? message,
    List<HomeContestBundle>? joinedContestsBundles,
    List<HomeContestBundle>? filteredContestsBundles,
  }) {
    return ParticipantHomePageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      joinedContestsBundles: joinedContestsBundles ?? this.joinedContestsBundles,
      filteredContestsBundles: filteredContestsBundles ?? this.filteredContestsBundles,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
        joinedContestsBundles,
        filteredContestsBundles,
      ];
}
