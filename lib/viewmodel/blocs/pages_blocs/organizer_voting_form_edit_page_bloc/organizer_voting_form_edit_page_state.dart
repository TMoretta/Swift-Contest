part of 'organizer_voting_form_edit_page_bloc.dart';

@immutable
final class OrganizerVotingFormEditPageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingFormEditPageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final VotingFormBundle? votingFormBundle;

  const OrganizerVotingFormEditPageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.votingFormBundle,
  });

  factory OrganizerVotingFormEditPageState.fromJson(Map<String, dynamic> json) {
    return OrganizerVotingFormEditPageState(
      status: BlocStatus.values.byName(json['status']),
      isInitialized: json['is_initialized'] as bool,
      votingFormBundle: (json['voting_form_bundle'] != null)
          ? VotingFormBundle.fromJson(json['voting_form_bundle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'is_initialized': isInitialized,
      'voting_form_bundle': votingFormBundle?.toJson(),
    };
  }

  OrganizerVotingFormEditPageState copyWith({
    required BlocStatus status,
    OrganizerVotingFormEditPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    VotingFormBundle? votingFormBundle,
  }) {
    return OrganizerVotingFormEditPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      votingFormBundle: votingFormBundle ?? this.votingFormBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        votingFormBundle,
      ];
}
