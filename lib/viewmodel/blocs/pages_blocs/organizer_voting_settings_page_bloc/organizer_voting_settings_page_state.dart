part of 'organizer_voting_settings_page_bloc.dart';

@immutable
final class OrganizerVotingSettingsPageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingSettingsPageEvent? sourceEvent;
  final String? message;
  final ContestDetailsBundle? contestDetailsBundle;
  final String? votingSessionId;

  const OrganizerVotingSettingsPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.contestDetailsBundle,
    this.votingSessionId,
  });

  OrganizerVotingSettingsPageState copyWith({
    required BlocStatus status,
    OrganizerVotingSettingsPageEvent? sourceEvent,
    String? message,
    ContestDetailsBundle? contestDetailsBundle,
    String? votingSessionId,
  }) {
    return OrganizerVotingSettingsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      contestDetailsBundle: contestDetailsBundle ?? this.contestDetailsBundle,
      votingSessionId: votingSessionId ?? this.votingSessionId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
        contestDetailsBundle,
        votingSessionId,
      ];
}
