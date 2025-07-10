part of 'organizer_home_page_bloc.dart';

sealed class OrganizerHomePageEvent extends Equatable {
  const OrganizerHomePageEvent();
}

final class OrganizerHomePageInit extends OrganizerHomePageEvent {
  @override
  List<Object?> get props => [];
}

final class OrganizerHomePageRefresh extends OrganizerHomePageEvent {
  @override
  List<Object?> get props => [];
}

final class OrganizerHomePageFilterResults extends OrganizerHomePageEvent {
  final String query;

  const OrganizerHomePageFilterResults({
    required this.query,
  });

  @override
  List<Object?> get props => [query];
}
