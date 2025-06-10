part of 'organizer_voting_form_edit_page_bloc.dart';

@immutable
final class OrganizerVotingFormEditPageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingFormEditPageEvent? sourceEvent;
  final String? message;
  final VotingFormBundle? votingFormBundle;

  const OrganizerVotingFormEditPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.votingFormBundle,
  });

  OrganizerVotingFormEditPageState copyWith({
    required BlocStatus status,
    OrganizerVotingFormEditPageEvent? sourceEvent,
    String? message,
    VotingFormBundle? votingFormBundle,
  }) {
    return OrganizerVotingFormEditPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      votingFormBundle: votingFormBundle,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, message, votingFormBundle];
}
