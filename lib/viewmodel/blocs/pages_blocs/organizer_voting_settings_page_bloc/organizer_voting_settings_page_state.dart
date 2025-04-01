part of 'organizer_voting_settings_page_bloc.dart';

@immutable
class OrganizerVotingSettingsPageState extends Equatable {
  final BlocStatus status;

  const OrganizerVotingSettingsPageState({required this.status});

  OrganizerVotingSettingsPageState copyWith({
    required BlocStatus status,
  }) {
    return OrganizerVotingSettingsPageState(
      status: status,
    );
  }

  @override
  List<Object?> get props => [status];
}
