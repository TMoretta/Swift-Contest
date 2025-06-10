part of 'organizer_home_page_bloc.dart';

sealed class OrganizerHomePageEvent extends Equatable {
  const OrganizerHomePageEvent();
}

final class OrganizerHomePageGetCreatedContests extends OrganizerHomePageEvent {
  final String organizerId;

  const OrganizerHomePageGetCreatedContests({required this.organizerId});

  @override
  List<Object?> get props => [organizerId];
}
