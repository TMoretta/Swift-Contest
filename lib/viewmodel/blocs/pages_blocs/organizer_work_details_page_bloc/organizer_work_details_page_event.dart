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
