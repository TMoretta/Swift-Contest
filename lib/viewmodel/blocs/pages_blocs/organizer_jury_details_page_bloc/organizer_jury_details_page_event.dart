part of 'organizer_jury_details_page_bloc.dart';

sealed class OrganizerJuryDetailsPageEvent extends Equatable {
  const OrganizerJuryDetailsPageEvent();
}

final class OrganizerJuryDetailsPageFetch extends OrganizerJuryDetailsPageEvent {
  final String juryId;

  const OrganizerJuryDetailsPageFetch({required this.juryId});

  @override
  List<Object?> get props => [juryId];
}

final class OrganizerJuryDetailsPageDeleteJury extends OrganizerJuryDetailsPageEvent {
  final String juryId;

  const OrganizerJuryDetailsPageDeleteJury({required this.juryId});

  @override
  List<Object?> get props => [juryId];
}

final class OrganizerJuryDetailsPageEditJury extends OrganizerJuryDetailsPageEvent {
  final String juryId;
  final String name;

  const OrganizerJuryDetailsPageEditJury({required this.juryId, required this.name,});

  @override
  List<Object?> get props => [juryId, name];
}

final class OrganizerJuryDetailsPageInviteJuror extends OrganizerJuryDetailsPageEvent {
  final String contestId;
  final String juryId;
  final String email;

  const OrganizerJuryDetailsPageInviteJuror({
    required this.contestId,
    required this.juryId,
    required this.email,
  });

  @override
  List<Object?> get props => [contestId, juryId, email];
}

final class OrganizerJuryDetailsPageRemoveJuror extends OrganizerJuryDetailsPageEvent {
  final String jurationId;

  const OrganizerJuryDetailsPageRemoveJuror({required this.jurationId});

  @override
  List<Object?> get props => [jurationId];
}

final class OrganizerJuryDetailsPageDeleteJurorInvitation extends OrganizerJuryDetailsPageEvent {
  final String jurorInvitationId;

  const OrganizerJuryDetailsPageDeleteJurorInvitation({required this.jurorInvitationId});

  @override
  List<Object?> get props => [jurorInvitationId];
}
