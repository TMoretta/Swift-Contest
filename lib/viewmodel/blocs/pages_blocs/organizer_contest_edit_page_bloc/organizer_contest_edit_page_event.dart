part of 'organizer_contest_edit_page_bloc.dart';

sealed class OrganizerContestEditPageEvent extends Equatable {
  const OrganizerContestEditPageEvent();
}

// final class OrganizerContestEditPageInit extends OrganizerContestEditPageEvent {
//   final String contestId;
//
//   const OrganizerContestEditPageInit({required this.contestId});
//
//   @override
//   List<Object?> get props => [contestId];
// }

final class OrganizerContestEditPageFetch extends OrganizerContestEditPageEvent {
  final String contestId;

  const OrganizerContestEditPageFetch({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class OrganizerContestEditPageEditContest extends OrganizerContestEditPageEvent {
  final String contestId;
  final String name;
  final String description;
  final Place place;
  final DateTime dateTime;
  final DateTime worksSubmissionStart;
  final DateTime worksSubmissionEnd;
  final List<String> oldImagesUrls;
  final List<XFile>? images;

  const OrganizerContestEditPageEditContest({
    required this.contestId,
    required this.name,
    required this.description,
    required this.place,
    required this.dateTime,
    required this.worksSubmissionStart,
    required this.worksSubmissionEnd,
    required this.oldImagesUrls,
    this.images,
  });

  @override
  List<Object?> get props => [
        contestId,
        name,
        description,
        place,
        dateTime,
        worksSubmissionStart,
        worksSubmissionEnd,
        oldImagesUrls,
        images,
      ];
}
