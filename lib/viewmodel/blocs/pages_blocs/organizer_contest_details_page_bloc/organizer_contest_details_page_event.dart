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

final class OrganizerContestDetailsPageGetContestMainInfo extends OrganizerContestDetailsPageEvent {
  final String contestId;

  const OrganizerContestDetailsPageGetContestMainInfo({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class OrganizerContestDetailsPageGetVotingTabInfo extends OrganizerContestDetailsPageEvent {
  final String contestId;

  const OrganizerContestDetailsPageGetVotingTabInfo({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class OrganizerContestDetailsPageUpdateVotingFormFields extends OrganizerContestDetailsPageEvent {
  final List<RawVotingFormField> rawVotingFormFields;
  final String votingFormId;

  const OrganizerContestDetailsPageUpdateVotingFormFields({required this.rawVotingFormFields, required this.votingFormId,});

  @override
  List<Object?> get props => [rawVotingFormFields, votingFormId];
}
