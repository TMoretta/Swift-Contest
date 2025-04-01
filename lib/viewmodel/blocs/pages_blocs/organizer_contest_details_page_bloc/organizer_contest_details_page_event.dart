part of 'organizer_contest_details_page_bloc.dart';

@immutable
sealed class OrganizerContestDetailsPageEvent extends Equatable {
  const OrganizerContestDetailsPageEvent();
}

final class OrganizerContestDetailsPageSendParticipantInvite
    extends OrganizerContestDetailsPageEvent {
  final Contest contest;
  final String email;

  const OrganizerContestDetailsPageSendParticipantInvite({
    required this.contest,
    required this.email,
  });

  @override
  List<Object> get props => [contest, email];
}

final class OrganizerContestDetailsPageSendJurorInvite extends OrganizerContestDetailsPageEvent {
  final Contest contest;
  final String email;

  const OrganizerContestDetailsPageSendJurorInvite({required this.contest, required this.email});

  @override
  List<Object?> get props => [contest, email];
}

final class OrganizerContestDetailsPageGetExtendedContest extends OrganizerContestDetailsPageEvent {
  final String contestId;

  const OrganizerContestDetailsPageGetExtendedContest({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

// final class OrganizerContestDetailsPageGetWorks extends OrganizerContestDetailsPageEvent {
//   final String contestId;
//
//   OrganizerContestDetailsPageGetWorks({required this.contestId});
// }

final class OrganizerContestDetailsPageGetVotingForm extends OrganizerContestDetailsPageEvent {
  final String contestId;

  const OrganizerContestDetailsPageGetVotingForm({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class OrganizerContestDetailsPageUpdateVotingForm extends OrganizerContestDetailsPageEvent {
  final String contestId;
  final List<VotingFormField> updatedFields;

  const OrganizerContestDetailsPageUpdateVotingForm({
    required this.contestId,
    required this.updatedFields,
  });

  @override
  List<Object?> get props => [contestId, updatedFields];
}

final class OrganizerContestDetailsPageCleanAndGetExtendedContest
    extends OrganizerContestDetailsPageEvent {
  final String contestId;

  const OrganizerContestDetailsPageCleanAndGetExtendedContest({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}
