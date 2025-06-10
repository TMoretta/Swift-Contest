part of 'organizer_voting_settings_page_bloc.dart';

@immutable
final class OrganizerVotingSettingsPageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingSettingsPageEvent? sourceEvent;
  final String? message;
  final OrganizerVotingSessionBundle? votingSessionBundle;

  const OrganizerVotingSettingsPageState({required this.status, this.sourceEvent, this.message, this.votingSessionBundle,});

  OrganizerVotingSettingsPageState copyWith({
    required BlocStatus status,
    OrganizerVotingSettingsPageEvent? sourceEvent,
    String? message,
    OrganizerVotingSessionBundle? votingSessionBundle,
  }) {
    return OrganizerVotingSettingsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      votingSessionBundle: votingSessionBundle ?? this.votingSessionBundle,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, message, votingSessionBundle];
}
