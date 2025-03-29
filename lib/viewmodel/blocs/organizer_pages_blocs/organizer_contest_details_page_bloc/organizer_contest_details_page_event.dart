part of 'organizer_contest_details_page_bloc.dart';

@immutable
sealed class OrganizerContestDetailsPageEvent {}

final class OrganizerContestDetailsPageSendParticipantInvite
    extends OrganizerContestDetailsPageEvent {
  final Contest contest;
  final String email;

  OrganizerContestDetailsPageSendParticipantInvite({
    required this.contest,
    required this.email,
  });
}

final class OrganizerContestDetailsPageSendJurorInvite extends OrganizerContestDetailsPageEvent {
  final Contest contest;
  final String email;

  OrganizerContestDetailsPageSendJurorInvite({required this.contest, required this.email});
}

final class OrganizerContestDetailsPageGetExtendedContest extends OrganizerContestDetailsPageEvent {
  final String contestId;

  OrganizerContestDetailsPageGetExtendedContest({required this.contestId});
}

final class OrganizerContestDetailsPageGetWorks extends OrganizerContestDetailsPageEvent {
  final String contestId;

  OrganizerContestDetailsPageGetWorks({required this.contestId});
}

final class OrganizerContestDetailsPageGetVotingForm extends OrganizerContestDetailsPageEvent {
  final String contestId;

  OrganizerContestDetailsPageGetVotingForm({required this.contestId});
}

final class OrganizerContestDetailsPageUpdateVotingForm extends OrganizerContestDetailsPageEvent {
  final String contestId;
  final List<VotingFormField> updatedFields;

  OrganizerContestDetailsPageUpdateVotingForm({required this.contestId, required this.updatedFields});

}

final class OrganizerContestDetailsPageClean extends OrganizerContestDetailsPageEvent {}
