part of 'juror_contest_details_page_bloc.dart';

@immutable
class JurorContestDetailsPageState {
  final BlocStatus status;
  final String? message;
  final Contest? contest;
  final Profile? organizer;
  final Participation? ownJuration;

  const JurorContestDetailsPageState({
    required this.status,
    this.message,
    this.contest,
    this.organizer,
    this.ownJuration,
  });

  JurorContestDetailsPageState copyWith({
    required BlocStatus status,
    String? message,
    Contest? contest,
    Profile? organizer,
    Participation? ownJuration,
    Work? ownWork,
  }) {
    return JurorContestDetailsPageState(
      status: status,
      message: message,
      contest: contest ?? this.contest,
      organizer: organizer ?? this.organizer,
      ownJuration: ownJuration ?? this.ownJuration,
    );
  }
}
