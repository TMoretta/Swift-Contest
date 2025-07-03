part of 'organizer_voting_settings_page_bloc.dart';

sealed class OrganizerVotingSettingsPageEvent extends Equatable {
  const OrganizerVotingSettingsPageEvent();
}

final class OrganizerVotingSettingsPageInit extends OrganizerVotingSettingsPageEvent {
  final String contestId;

  const OrganizerVotingSettingsPageInit({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class OrganizerVotingSettingsPageRefresh extends OrganizerVotingSettingsPageEvent {
  final String contestId;

  const OrganizerVotingSettingsPageRefresh({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class OrganizerVotingSettingsPageInitVotingProcedure
    extends OrganizerVotingSettingsPageEvent {
  final String contestId;
  final String votingFormId;
  final bool areSimpleJurorsAllowed;
  final List<ParticipationBundle> participationsBundles;
  final List<ParticipationBundle> excludedParticipationsBundles;
  final List<JurationBundle> jurationsBundles;
  final List<JurationBundle> excludedJurationsBundles;
  final List<VotingExclusionBundle> votingExclusionsBundles;
  final Duration workTimer;
  final Duration intermissionTimer;
  final Duration reviewTimer;
  final bool isGeoRestricted;
  final List<VotingFormFieldModel> votingFormFields;
  final String? geoRestrictionPlaceAddress;
  final double? geoRestrictionPlaceLon;
  final double? geoRestrictionPlaceLat;
  final int? geoRestrictionRadius;


  const OrganizerVotingSettingsPageInitVotingProcedure({
    required this.contestId,
    required this.votingFormId,
    required this.areSimpleJurorsAllowed,
    required this.participationsBundles,
    required this.excludedParticipationsBundles,
    required this.jurationsBundles,
    required this.excludedJurationsBundles,
    required this.votingExclusionsBundles,
    required this.workTimer,
    required this.intermissionTimer,
    required this.reviewTimer,
    required this.votingFormFields,
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
    participationsBundles,
    excludedParticipationsBundles,
    jurationsBundles,
    excludedJurationsBundles,
    isGeoRestricted,
    geoRestrictionPlaceAddress,
    geoRestrictionPlaceLat,
    geoRestrictionPlaceLon,
    geoRestrictionRadius,
  ];
}
