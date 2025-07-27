part of 'organizer_voting_settings_page_bloc.dart';

sealed class OrganizerVotingSettingsPageEvent extends Equatable {
  const OrganizerVotingSettingsPageEvent();
}

final class OrganizerVotingSettingsPageFetch extends OrganizerVotingSettingsPageEvent {
  final String contestId;

  const OrganizerVotingSettingsPageFetch({required this.contestId});

  @override
  List<Object?> get props => [contestId];
}

final class OrganizerVotingSettingsPageInitVotingProcedure
    extends OrganizerVotingSettingsPageEvent {
  final VotingSession votingSession;
  final Place? geoResPlace;
  final List<ParticipationBundle> participationsBundles;
  final List<({JurationBundle jurationBundle, ParticipationBundle participationBundle})>
      votingExclusions;

  const OrganizerVotingSettingsPageInitVotingProcedure({
    required this.votingSession,
    required this.geoResPlace,
    required this.participationsBundles,
    required this.votingExclusions,
  });

  @override
  List<Object?> get props => [
        votingSession,
        geoResPlace,
        participationsBundles,
        votingExclusions,
      ];
}
