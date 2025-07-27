part of 'organizer_contest_creation_page_bloc.dart';

sealed class OrganizerContestCreationPageEvent extends Equatable {
  const OrganizerContestCreationPageEvent();
}

final class OrganizerContestCreationPageCreateContest extends OrganizerContestCreationPageEvent {
  final String organizerFullName;
  final String name;
  final String description;
  final DateTime dateTime;
  final DateTime worksSubmissionStart;
  final DateTime worksSubmissionEnd;
  final List<XFile> images;
  final String placeAddress;
  final double placeLon;
  final double placeLat;

  const OrganizerContestCreationPageCreateContest({
    required this.organizerFullName,
    required this.name,
    required this.description,
    required this.dateTime,
    required this.worksSubmissionStart,
    required this.worksSubmissionEnd,
    required this.images,
    required this.placeAddress,
    required this.placeLon,
    required this.placeLat,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    dateTime,
    worksSubmissionStart,
    worksSubmissionEnd,
    images,
    placeAddress,
    placeLon,
    placeLat,
  ];
}
