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
  final String juryId;
  final String email;

  const OrganizerContestDetailsPageSendJurorInvite({
    required this.contestId,
    required this.juryId,
    required this.email,
  });

  @override
  List<Object?> get props => [contestId, email];
}

final class OrganizerContestDetailsPageDeleteParticipantInvitation
    extends OrganizerContestDetailsPageEvent {
  final String participantInvitationId;

  const OrganizerContestDetailsPageDeleteParticipantInvitation(
      {required this.participantInvitationId});

  @override
  List<Object?> get props => [participantInvitationId];
}

final class OrganizerContestDetailsPageDeleteJurorInvitation
    extends OrganizerContestDetailsPageEvent {
  final String jurorInvitationId;

  const OrganizerContestDetailsPageDeleteJurorInvitation({required this.jurorInvitationId});

  @override
  List<Object?> get props => [jurorInvitationId];
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

final class OrganizerContestDetailsPageCreateJury extends OrganizerContestDetailsPageEvent {
  final String contestId;
  final String juryName;
  final JuryType juryType;


  const OrganizerContestDetailsPageCreateJury({
    required this.contestId,
    required this.juryName,
    required this.juryType,
  });

  @override
  List<Object?> get props => [
        contestId,
        juryName,
        juryType,
      ];
}

final class OrganizerContestDetailsPageRegenerateToken extends OrganizerContestDetailsPageEvent {
  final String contestId;

  const OrganizerContestDetailsPageRegenerateToken({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}
