part of 'organizer_voting_form_edit_page_bloc.dart';

sealed class OrganizerVotingFormEditPageEvent extends Equatable {
  const OrganizerVotingFormEditPageEvent();
}

final class OrganizerVotingFormEditPageInit extends OrganizerVotingFormEditPageEvent {
  final String votingFormId;

  const OrganizerVotingFormEditPageInit({required this.votingFormId});

  @override
  List<Object?> get props => [votingFormId];
}

final class OrganizerVotingFormEditPageUpdateVotingForm extends OrganizerVotingFormEditPageEvent {
  final String votingFormId;
  final List<VotingFormFieldModel> votingFormFields;

  const OrganizerVotingFormEditPageUpdateVotingForm({
    required this.votingFormId,
    required this.votingFormFields,
  });

  @override
  List<Object?> get props => [votingFormId, votingFormFields];
}
