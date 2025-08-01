part of 'organizer_voting_settings_page_bloc.dart';

@immutable
final class OrganizerVotingSettingsPageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingSettingsPageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final ContestDetailsBundle? contestDetailsBundle;
  final String? votingSessionId;

  const OrganizerVotingSettingsPageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.contestDetailsBundle,
    this.votingSessionId,
  });

  factory OrganizerVotingSettingsPageState.fromJson(Map<String, dynamic> json) {
    return OrganizerVotingSettingsPageState(
      status: BlocStatus.values.byName(json['status']),
      isInitialized: json['is_initialized'] as bool,
      contestDetailsBundle: (json['contest_details_bundle'] != null)
          ? ContestDetailsBundle.fromJson(json['contest_details_bundle'])
          : null,
      votingSessionId: json['voting_session_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'is_initialized': isInitialized,
      'contest_details_bundle': contestDetailsBundle?.toJson(),
      'voting_session_id': votingSessionId,
    };
  }

  OrganizerVotingSettingsPageState copyWith({
    required BlocStatus status,
    OrganizerVotingSettingsPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    ContestDetailsBundle? contestDetailsBundle,
    String? votingSessionId,
  }) {
    return OrganizerVotingSettingsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      contestDetailsBundle: contestDetailsBundle ?? this.contestDetailsBundle,
      votingSessionId: votingSessionId ?? this.votingSessionId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        contestDetailsBundle,
        votingSessionId,
      ];
}
