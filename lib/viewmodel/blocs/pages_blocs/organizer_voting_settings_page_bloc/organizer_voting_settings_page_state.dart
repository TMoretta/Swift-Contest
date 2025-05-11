part of 'organizer_voting_settings_page_bloc.dart';

@immutable
class OrganizerVotingSettingsPageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final VotingSession? votingSession;

  const OrganizerVotingSettingsPageState({
    required this.status,
    this.message,
    this.votingSession,
  });

  OrganizerVotingSettingsPageState copyWith({
    required BlocStatus status,
    String? message,
    VotingSession? votingSession,
  }) {
    return OrganizerVotingSettingsPageState(
      status: status,
      message: message,
      votingSession: votingSession,
    );
  }

  @override
  List<Object?> get props => [status, message, votingSession];
}
