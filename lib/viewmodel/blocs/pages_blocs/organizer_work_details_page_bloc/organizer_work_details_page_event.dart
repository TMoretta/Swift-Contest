part of 'organizer_work_details_page_bloc.dart';

sealed class OrganizerWorkDetailsPageEvent extends Equatable {
  const OrganizerWorkDetailsPageEvent();
}

final class OrganizerWorkDetailsPageFetch extends OrganizerWorkDetailsPageEvent {
  final String participationId;

  const OrganizerWorkDetailsPageFetch({required this.participationId});

  @override
  List<Object?> get props => [participationId];
}

final class OrganizerWorkDetailsPageGetWorkFileUrl extends OrganizerWorkDetailsPageEvent {
  final String filePath;

  const OrganizerWorkDetailsPageGetWorkFileUrl({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}
