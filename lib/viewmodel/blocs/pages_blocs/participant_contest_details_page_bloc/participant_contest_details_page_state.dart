part of 'participant_contest_details_page_bloc.dart';

@immutable
final class ParticipantContestDetailsPageState extends Equatable {
  final BlocStatus status;
  final ParticipantContestDetailsPageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final ContestDetailsBundle? contestDetailsBundle;
  final Work? submittedWork;
  // final Participation? ownParticipation;

  const ParticipantContestDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.contestDetailsBundle,
    this.submittedWork,
    // this.ownParticipation,
  });

  ParticipantContestDetailsPageState copyWith({
    required BlocStatus status,
    ParticipantContestDetailsPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    ContestDetailsBundle? contestDetailsBundle,
    Work? submittedWork,
    Participation? ownParticipation,
  }) {
    return ParticipantContestDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      contestDetailsBundle: contestDetailsBundle ?? this.contestDetailsBundle,
      submittedWork: submittedWork ?? this.submittedWork,
      // ownParticipation: ownParticipation ?? this.ownParticipation,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        contestDetailsBundle,
        submittedWork,
        // ownParticipation,
      ];
}
