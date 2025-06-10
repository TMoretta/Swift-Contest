part of 'organizer_contest_creation_page_bloc.dart';

sealed class OrganizerContestCreationPageEvent extends Equatable {
  const OrganizerContestCreationPageEvent();
}

final class OrganizerContestCreationPageCreateContest extends OrganizerContestCreationPageEvent {
  final String organizerId;
  final String name;
  final String description;
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
    dateTime,
    worksSubmissionFrom,
    worksSubmissionTo,
    images,
    placeAddress,
    placeLon,
    placeLat,
  ];
}
