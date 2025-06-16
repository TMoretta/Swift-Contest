part of 'organizer_voting_settings_page_bloc.dart';

sealed class OrganizerVotingSettingsPageEvent extends Equatable {
  const OrganizerVotingSettingsPageEvent();
}

final class OrganizerVotingSettingsPageInitVotingProcedure
    extends OrganizerVotingSettingsPageEvent {
  final String contestId;
  final String votingFormId;
  final bool areSimpleJurorsAllowed;
  final List<ParticipationBundle> votingParticipationsBundles;
  final List<JurationBundle> votingJurationsBundles;
  final List<VotingExclusionBundle> votingExclusionsBundles;
  final Duration workTimer;
  final Duration intermissionTimer;
  final Duration reviewTimer;
  final bool isGeoRestricted;
  final String? geoRestrictionPlaceAddress;
  final double? geoRestrictionPlaceLon;
  final double? geoRestrictionPlaceLat;
  final int? geoRestrictionRadius;


  const OrganizerVotingSettingsPageInitVotingProcedure({
    required this.contestId,
    required this.votingFormId,
    required this.areSimpleJurorsAllowed,
    required this.votingParticipationsBundles,
    required this.votingJurationsBundles,
    required this.votingExclusionsBundles,
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
    votingExclusionsBundles,
    workTimer,
    intermissionTimer,
    reviewTimer,
    votingParticipationsBundles,
    votingJurationsBundles,
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
