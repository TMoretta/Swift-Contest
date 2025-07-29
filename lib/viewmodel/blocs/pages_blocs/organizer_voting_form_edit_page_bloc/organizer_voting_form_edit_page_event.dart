part of 'organizer_voting_form_edit_page_bloc.dart';

sealed class OrganizerVotingFormEditPageEvent extends Equatable {
  const OrganizerVotingFormEditPageEvent();
}

final class OrganizerVotingFormEditPageFetch extends OrganizerVotingFormEditPageEvent {
  final String votingFormId;

  const OrganizerVotingFormEditPageFetch({required this.votingFormId});

  @override
  List<Object?> get props => [votingFormId];
}

final class OrganizerVotingFormEditPageUpdateVotingForm extends OrganizerVotingFormEditPageEvent {
  final String votingFormId;
  final List<VotingFormField> votingFormFields;
  final String? header;
  final String? footer;


  const OrganizerVotingFormEditPageUpdateVotingForm({
    required this.votingFormId,
    required this.votingFormFields,
    required this.header,
    required this.footer,
  });

  @override
  List<Object?> get props => [votingFormId, votingFormFields, header, footer];
}
