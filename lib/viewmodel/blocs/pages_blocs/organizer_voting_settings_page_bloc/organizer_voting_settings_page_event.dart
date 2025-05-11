part of 'organizer_voting_settings_page_bloc.dart';

@immutable
sealed class OrganizerVotingSettingsPageEvent extends Equatable {
  const OrganizerVotingSettingsPageEvent();
}

final class OrganizerVotingSettingsPageCreateVotingSessionAndBeginProcedure
    extends OrganizerVotingSettingsPageEvent {
  final String contestId;
  final String votingFormId;
  final bool isSimpleJurorAllowed;
  final List<Participant> votingParticipants;
  final List<Juror> votingJurors;
  final List<ParticipantAndJuror> votingExclusions;
  final Duration workTimer;
  final Duration intermissionTimer;
  final Duration reviewTimer;

  const OrganizerVotingSettingsPageCreateVotingSessionAndBeginProcedure({
    required this.contestId,
    required this.votingFormId,
    required this.isSimpleJurorAllowed,
    required this.votingParticipants,
    required this.votingJurors,
    required this.votingExclusions,
    required this.workTimer,
    required this.intermissionTimer,
    required this.reviewTimer,
  });

  @override
  List<Object?> get props => [
        contestId,
        votingFormId,
        isSimpleJurorAllowed,
        votingExclusions,
        workTimer,
        intermissionTimer,
        reviewTimer,
        votingParticipants,
        votingJurors,
      ];
}

final class OrganizerVotingSettingsPageStartVotingSessionProcedure extends OrganizerVotingSettingsPageEvent {
  final String votingSessionId;

  const OrganizerVotingSettingsPageStartVotingSessionProcedure({required this.votingSessionId});

  @override
  // TODO: implement props
  List<Object?> get props => [votingSessionId];
}
