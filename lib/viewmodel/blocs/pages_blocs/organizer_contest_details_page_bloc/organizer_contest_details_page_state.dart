part of 'organizer_contest_details_page_bloc.dart';

@immutable
final class OrganizerContestDetailsPageState extends Equatable {
  final BlocStatus status;
  final OrganizerContestDetailsPageEvent? sourceEvent;
  final String? message;
  final ContestDetailsBundle? contestDetailsBundle;

  const OrganizerContestDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.contestDetailsBundle,
  });

  OrganizerContestDetailsPageState copyWith({
    required BlocStatus status,
    OrganizerContestDetailsPageEvent? sourceEvent,
    String? message,
    ContestDetailsBundle? contestDetailsBundle,
  }) {
    return OrganizerContestDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      contestDetailsBundle: contestDetailsBundle ?? this.contestDetailsBundle,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, message, contestDetailsBundle];
}