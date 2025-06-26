part of 'organizer_voting_form_edit_page_bloc.dart';

sealed class OrganizerVotingFormEditPageEvent extends Equatable {
  const OrganizerVotingFormEditPageEvent();
}

final class OrganizerVotingFormEditPageGetVotingForm extends OrganizerVotingFormEditPageEvent {
  final String votingFormId;

  const OrganizerVotingFormEditPageGetVotingForm({required this.votingFormId});

  @override
  List<Object?> get props => [votingFormId];
}

final class OrganizerVotingFormEditPageUpdateVotingForm extends OrganizerVotingFormEditPageEvent {
  final String votingFormId;
  final List<VotingFormFieldNullable> votingFormFields;

  const OrganizerVotingFormEditPageUpdateVotingForm({
    required this.votingFormId,
    required this.votingFormFields,
  });

  @override
  List<Object?> get props => [votingFormId, votingFormFields];
}
