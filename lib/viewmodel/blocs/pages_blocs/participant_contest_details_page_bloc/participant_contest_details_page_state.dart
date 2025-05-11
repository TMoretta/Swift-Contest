part of 'participant_contest_details_page_bloc.dart';

@immutable
class ParticipantContestDetailsPageState {
  final BlocStatus status;
  final String? message;
  final Contest? contest;
  final Place? place;
  final Profile? organizer;
  final Participation? ownParticipation;
  final Work? ownWork;

  const ParticipantContestDetailsPageState({
    required this.status,
    this.message,
     this.contest,
    this.place,
     this.organizer,
     this.ownParticipation,
     this.ownWork,
  });

  ParticipantContestDetailsPageState copyWith({
    required BlocStatus status,
    String? message,
    Contest? contest,
    Place? place,
    Profile? organizer,
    Participation? ownParticipation,
    Work? ownWork,
  }) {
    return ParticipantContestDetailsPageState(
      status: status,
      message: message,
      place: place ?? this.place,
      contest: contest ?? this.contest,
      organizer: organizer ?? this.organizer,
      ownParticipation: ownParticipation ?? this.ownParticipation,
      ownWork: ownWork ?? this.ownWork,
    );
  }
}
