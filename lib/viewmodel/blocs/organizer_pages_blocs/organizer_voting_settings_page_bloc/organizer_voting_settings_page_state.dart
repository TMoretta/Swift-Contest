part of 'organizer_voting_settings_page_bloc.dart';

@immutable
class OrganizerVotingSettingsPageState {
  final BlocStatus status;

  const OrganizerVotingSettingsPageState({required this.status});

  OrganizerVotingSettingsPageState copyWith({
    required BlocStatus status,
  }) {
    return OrganizerVotingSettingsPageState(
      status: status,
    );
  }
}
