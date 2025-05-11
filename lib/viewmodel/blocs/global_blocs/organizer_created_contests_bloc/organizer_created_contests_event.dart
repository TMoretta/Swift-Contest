part of 'organizer_created_contests_bloc.dart';

sealed class OrganizerCreatedContestsEvent extends Equatable {
  const OrganizerCreatedContestsEvent();
}

final class OrganizerCreatedContestsGetCreatedContests extends OrganizerCreatedContestsEvent {
  final String organizerId;

  const OrganizerCreatedContestsGetCreatedContests({required this.organizerId});

  @override
  List<Object> get props => [organizerId];
}

final class OrganizerCreatedContestsClear extends OrganizerCreatedContestsEvent {
  @override
  List<Object?> get props => [];
}

