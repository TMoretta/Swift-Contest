part of 'organizer_contest_details_page_bloc.dart';

sealed class OrganizerContestDetailsPageEvent extends Equatable {
  const OrganizerContestDetailsPageEvent();
}

final class OrganizerContestDetailsPageFetch extends OrganizerContestDetailsPageEvent {
  final String contestId;

  const OrganizerContestDetailsPageFetch({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class OrganizerContestDetailsPageSendParticipantInvite
    extends OrganizerContestDetailsPageEvent {
  final String contestId;
  final String email;

  const OrganizerContestDetailsPageSendParticipantInvite({
    required this.contestId,
    required this.email,
  });

  @override
  List<Object> get props => [contestId, email];
}

final class OrganizerContestDetailsPageSendJurorInvite extends OrganizerContestDetailsPageEvent {
  final String contestId;
  final String email;

  const OrganizerContestDetailsPageSendJurorInvite({required this.contestId, required this.email});

  @override
  List<Object?> get props => [contestId, email];
}

final class OrganizerContestDetailsPageDeleteInvitation extends OrganizerContestDetailsPageEvent {
  final String invitationId;

  const OrganizerContestDetailsPageDeleteInvitation({required this.invitationId});

  @override
  List<Object?> get props => [invitationId];
}

final class OrganizerContestDetailsPageRemoveParticipant extends OrganizerContestDetailsPageEvent {
  final String participationId;

  const OrganizerContestDetailsPageRemoveParticipant({
    required this.participationId,
  });

  @override
  List<Object?> get props => [participationId];
}

final class OrganizerContestDetailsPageRemoveJuror extends OrganizerContestDetailsPageEvent {
  final String jurationId;

  const OrganizerContestDetailsPageRemoveJuror({
    required this.jurationId,
  });

  @override
  List<Object?> get props => [jurationId];
}

final class OrganizerContestDetailsPageEditVotingSessionName
    extends OrganizerContestDetailsPageEvent {
  final String votingSessionId;
  final String name;

  const OrganizerContestDetailsPageEditVotingSessionName({
    required this.votingSessionId,
    required this.name,
  });

  @override
  List<Object?> get props => [votingSessionId, name];
}

final class OrganizerContestDetailsPageDeleteContest extends OrganizerContestDetailsPageEvent {
  final String contestId;

  const OrganizerContestDetailsPageDeleteContest({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class OrganizerContestDetailsPageSetStatusAsActive extends OrganizerContestDetailsPageEvent {
  final String contestId;

  const OrganizerContestDetailsPageSetStatusAsActive({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class OrganizerContestDetailsPageSetStatusAsTerminated extends OrganizerContestDetailsPageEvent {
  final String contestId;

  const OrganizerContestDetailsPageSetStatusAsTerminated({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}
