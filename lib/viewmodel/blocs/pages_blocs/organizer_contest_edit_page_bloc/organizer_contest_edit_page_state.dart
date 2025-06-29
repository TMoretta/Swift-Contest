part of 'organizer_contest_edit_page_bloc.dart';

@immutable
final class OrganizerContestEditPageState extends Equatable {
  final BlocStatus status;
  final OrganizerContestEditPageEvent? sourceEvent;
  final String? message;
  final ContestDetailsBundle? contestDetailsBundle;

  const OrganizerContestEditPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.contestDetailsBundle,
  });

  OrganizerContestEditPageState copyWith({
    required BlocStatus status,
    OrganizerContestEditPageEvent? sourceEvent,
    String? message,
    ContestDetailsBundle? contestDetailsBundle,
  }) {
    return OrganizerContestEditPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      contestDetailsBundle: contestDetailsBundle ?? this.contestDetailsBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
        contestDetailsBundle,
      ];
}
