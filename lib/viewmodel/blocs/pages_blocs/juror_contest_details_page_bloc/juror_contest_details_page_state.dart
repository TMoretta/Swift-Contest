part of 'juror_contest_details_page_bloc.dart';

@immutable
final class JurorContestDetailsPageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final Contest? contest;
  final Place? place;
  final Profile? organizer;
  final bool isVotingSessionProcedureLive;

  const JurorContestDetailsPageState({
    required this.status,
    this.message,
    this.contest,
    this.place,
    this.organizer,
    this.isVotingSessionProcedureLive = false,
  });

  JurorContestDetailsPageState copyWith({
    required BlocStatus status,
    String? message,
    Contest? contest,
    Profile? organizer,
    Place? place,
    bool? isVotingSessionProcedureLive,
  }) {
    return JurorContestDetailsPageState(
      status: status,
      message: message,
      contest: contest ?? this.contest,
      organizer: organizer ?? this.organizer,
      place: place ?? this.place,
      isVotingSessionProcedureLive: isVotingSessionProcedureLive ?? this.isVotingSessionProcedureLive,
    );
  }

  @override
  List<Object?> get props => [status, message, contest, organizer, place, isVotingSessionProcedureLive,];
}
