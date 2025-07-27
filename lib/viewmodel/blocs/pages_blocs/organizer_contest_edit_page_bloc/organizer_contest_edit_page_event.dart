part of 'organizer_contest_edit_page_bloc.dart';

sealed class OrganizerContestEditPageEvent extends Equatable {
  const OrganizerContestEditPageEvent();
}

final class OrganizerContestEditPageFetch extends OrganizerContestEditPageEvent {
  final String contestId;

  const OrganizerContestEditPageFetch({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class OrganizerContestEditPageEditContest extends OrganizerContestEditPageEvent {
  final Contest contest;
  final Place place;
  final List<XFile> images;

  const OrganizerContestEditPageEditContest({
    required this.contest,
    required this.place,
    required this.images,
  });

  @override
  List<Object?> get props => [
        contest,
    place,
        images,
      ];
}
