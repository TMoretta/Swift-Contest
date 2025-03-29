part of 'organizer_contest_creation_page_bloc.dart';

@immutable
sealed class OrganizerContestCreationPageEvent {}

final class OrganizerContestCreationPageCreateContest extends OrganizerContestCreationPageEvent {
  final String name;
  final String description;
  final String organizerId;
  final Place place;
  final bool worksPreviewJurors;
  final DateTime dateTime;
  final DateTime worksDateTimeFrom;
  final DateTime worksDateTimeTo;
  final List<XFile> images;

  OrganizerContestCreationPageCreateContest({
    required this.name,
    required this.description,
    required this.organizerId,
    required this.place,
    required this.worksPreviewJurors,
    required this.dateTime,
    required this.worksDateTimeFrom,
    required this.worksDateTimeTo,
    required this.images,
  });
}

