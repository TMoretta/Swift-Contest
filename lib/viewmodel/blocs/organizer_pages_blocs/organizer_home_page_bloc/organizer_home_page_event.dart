part of 'organizer_home_page_bloc.dart';

@immutable
sealed class OrganizerHomePageEvent {}

final class OrganizerHomePageGetCreatedContestsExtended extends OrganizerHomePageEvent {
  final String organizerId;

  OrganizerHomePageGetCreatedContestsExtended({required this.organizerId});
}

// final class OrganizerHomePageGetExtendedContest extends OrganizerHomePageEvent {
//   final String contestId;
//
//   OrganizerHomePageGetExtendedContest({required this.contestId});
// }

