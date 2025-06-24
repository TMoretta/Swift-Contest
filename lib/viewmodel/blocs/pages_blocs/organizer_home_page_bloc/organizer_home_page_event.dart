part of 'organizer_home_page_bloc.dart';

sealed class OrganizerHomePageEvent extends Equatable {
  const OrganizerHomePageEvent();
}

final class OrganizerHomePageInit extends OrganizerHomePageEvent {
  final String userId;

  const OrganizerHomePageInit({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final class OrganizerHomePageRefresh extends OrganizerHomePageEvent {
  final String userId;

  const OrganizerHomePageRefresh({required this.userId});

  @override
  List<Object?> get props => [userId];
}
