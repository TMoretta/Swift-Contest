part of 'organizer_contest_creation_page_bloc.dart';

@immutable
final class OrganizerContestCreationPageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final Contest? contest;

  const OrganizerContestCreationPageState({
    required this.status,
    this.message,
    this.contest,
  });

  OrganizerContestCreationPageState copyWith({
    required BlocStatus status,
    String? message,
    Contest? contest,
  }) {
    return OrganizerContestCreationPageState(
      status: status,
      message: message,
      contest: contest ?? this.contest,
    );
  }

  @override
  List<Object?> get props => [status, message, contest];
}
