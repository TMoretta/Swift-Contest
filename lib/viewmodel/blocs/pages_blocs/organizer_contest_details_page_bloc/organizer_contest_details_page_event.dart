part of 'organizer_contest_details_page_bloc.dart';

sealed class OrganizerContestDetailsPageEvent extends Equatable {
  const OrganizerContestDetailsPageEvent();
}

final class OrganizerContestDetailsPageInit extends OrganizerContestDetailsPageEvent {
  final String contestId;

  const OrganizerContestDetailsPageInit({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class OrganizerContestDetailsPageRefresh extends OrganizerContestDetailsPageEvent {
  final String contestId;

  const OrganizerContestDetailsPageRefresh({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

// final class OrganizerContestDetailsPageGetRemainingInfo extends OrganizerContestDetailsPageEvent {
//   final HomeContestBundle homeContestBundle;
//
//   const OrganizerContestDetailsPageGetRemainingInfo({required this.homeContestBundle});
//
//   @override
//   List<Object?> get props => [homeContestBundle];
// }

final class OrganizerContestDetailsPageSendParticipantInvite extends OrganizerContestDetailsPageEvent {
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