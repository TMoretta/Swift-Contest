part of 'participant_contest_details_page_bloc.dart';

@immutable
final class ParticipantContestDetailsPageState extends Equatable {
  final BlocStatus status;
  final ParticipantContestDetailsPageEvent? sourceEvent;
  final String? message;
  final ContestDetailsBundle? contestDetailsBundle;
  final Work? submittedWork;
  // final Participation? ownParticipation;

  const ParticipantContestDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.contestDetailsBundle,
    this.submittedWork,
    // this.ownParticipation,
  });

  ParticipantContestDetailsPageState copyWith({
    required BlocStatus status,
    ParticipantContestDetailsPageEvent? sourceEvent,
    String? message,
    ContestDetailsBundle? contestDetailsBundle,
    Work? submittedWork,
    Participation? ownParticipation,
  }) {
    return ParticipantContestDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
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
        message,
        contestDetailsBundle,
        submittedWork,
        // ownParticipation,
      ];
}
