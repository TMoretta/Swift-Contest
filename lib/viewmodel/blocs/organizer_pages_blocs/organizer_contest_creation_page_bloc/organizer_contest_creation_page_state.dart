part of 'organizer_contest_creation_page_bloc.dart';

@immutable
sealed class OrganizerContestCreationPageState {}

final class OrganizerContestCreationPageInitial extends OrganizerContestCreationPageState {}

final class OrganizerContestCreationPageLoading extends OrganizerContestCreationPageState {}

final class OrganizerContestCreationPageSuccess extends OrganizerContestCreationPageState {
  final Contest contest;

  OrganizerContestCreationPageSuccess({required this.contest});
}

final class OrganizerContestCreationPageFailure extends OrganizerContestCreationPageState {
  final String message;

  OrganizerContestCreationPageFailure({required this.message});
}


