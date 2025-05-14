part of 'organizer_voting_settings_page_bloc.dart';

@immutable
sealed class OrganizerVotingSettingsPageEvent extends Equatable {
  const OrganizerVotingSettingsPageEvent();
}

final class OrganizerVotingSettingsPageCreateVotingSessionAndBeginProcedure
    extends OrganizerVotingSettingsPageEvent {
  final String contestId;
  final String votingFormId;
  final bool areSimpleJurorsAllowed;
  final List<Participant> votingParticipants;
  final List<Juror> votingJurors;
  final List<ParticipantAndJuror> votingExclusions;
  final Duration workTimer;
  final Duration intermissionTimer;
  final Duration reviewTimer;
  final bool isGeoRestricted;
  final String? geoRestrictionPlaceAddress;
  final double? geoRestrictionPlaceLon;
  final double? geoRestrictionPlaceLat;
  final int? geoRestrictionRadius;


  const OrganizerVotingSettingsPageCreateVotingSessionAndBeginProcedure({
    required this.contestId,
    required this.votingFormId,
    required this.areSimpleJurorsAllowed,
    required this.votingParticipants,
    required this.votingJurors,
    required this.votingExclusions,
    required this.workTimer,
    required this.intermissionTimer,
    required this.reviewTimer,
    required this.isGeoRestricted,
    this.geoRestrictionPlaceAddress,
    this.geoRestrictionPlaceLat,
    this.geoRestrictionPlaceLon,
    this.geoRestrictionRadius,
  });

  @override
  List<Object?> get props => [
        contestId,
        votingFormId,
        areSimpleJurorsAllowed,
        votingExclusions,
        workTimer,
        intermissionTimer,
        reviewTimer,
        votingParticipants,
        votingJurors,
        isGeoRestricted,
        geoRestrictionPlaceAddress,
        geoRestrictionPlaceLat,
        geoRestrictionPlaceLon,
        geoRestrictionRadius,
      ];
}

final class OrganizerVotingSettingsPageStartVotingSessionProcedure extends OrganizerVotingSettingsPageEvent {
  final String votingSessionId;

  const OrganizerVotingSettingsPageStartVotingSessionProcedure({required this.votingSessionId});

  @override
  List<Object?> get props => [votingSessionId];
}
