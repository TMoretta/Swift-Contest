part of 'organizer_contest_creation_page_bloc.dart';

@immutable
sealed class OrganizerContestCreationPageEvent extends Equatable {
  const OrganizerContestCreationPageEvent();
}

final class OrganizerContestCreationPageCreateContest extends OrganizerContestCreationPageEvent {
  final String organizerId;
  final String name;
  final String description;
  final bool isJurorsWorksPreviewEnabled;
  final DateTime dateTime;
  final DateTime worksSubmissionFrom;
  final DateTime worksSubmissionTo;
  final List<XFile> images;
  final String placeAddress;
  final double placeLon;
  final double placeLat;

  const OrganizerContestCreationPageCreateContest({
    required this.organizerId,
    required this.name,
    required this.description,
    required this.isJurorsWorksPreviewEnabled,
    required this.dateTime,
    required this.worksSubmissionFrom,
    required this.worksSubmissionTo,
    required this.images,
    required this.placeAddress,
    required this.placeLon,
    required this.placeLat,
  });

  @override
  List<Object?> get props => [
        organizerId,
        name,
        description,
        isJurorsWorksPreviewEnabled,
        dateTime,
        worksSubmissionFrom,
        worksSubmissionTo,
        placeAddress,
        placeLat,
        placeLon,
        images,
      ];
}
