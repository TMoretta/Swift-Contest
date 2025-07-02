part of 'organizer_home_page_bloc.dart';

sealed class OrganizerHomePageEvent extends Equatable {
  const OrganizerHomePageEvent();
}

final class OrganizerHomePageInit extends OrganizerHomePageEvent {
  final String organizerId;

  const OrganizerHomePageInit({required this.organizerId});

  @override
  List<Object?> get props => [organizerId];
}

final class OrganizerHomePageRefresh extends OrganizerHomePageEvent {
  final String organizerId;

  const OrganizerHomePageRefresh({required this.organizerId});

  @override
  List<Object?> get props => [organizerId];
}
