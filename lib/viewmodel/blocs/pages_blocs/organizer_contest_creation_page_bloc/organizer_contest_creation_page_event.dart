part of 'organizer_contest_creation_page_bloc.dart';

@immutable
sealed class OrganizerContestCreationPageEvent extends Equatable {
  const OrganizerContestCreationPageEvent();
}

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

  const OrganizerContestCreationPageCreateContest({
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

  @override
  List<Object?> get props => [
        name,
        description,
        organizerId,
        place,
        worksPreviewJurors,
        dateTime,
        worksDateTimeFrom,
        worksDateTimeTo,
        images,
      ];
}
