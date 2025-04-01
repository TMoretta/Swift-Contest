part of 'juror_contest_details_page_bloc.dart';

@immutable
final class JurorContestDetailsPageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final Contest? contest;
  final Profile? organizer;

  const JurorContestDetailsPageState({
    required this.status,
    this.message,
    this.contest,
    this.organizer,
  });

  JurorContestDetailsPageState copyWith({
    required BlocStatus status,
    String? message,
    Contest? contest,
    Profile? organizer,
  }) {
    return JurorContestDetailsPageState(
      status: status,
      message: message,
      contest: contest ?? this.contest,
      organizer: organizer ?? this.organizer,
    );
  }

  @override
  List<Object?> get props => [status, message, contest, organizer];
}
