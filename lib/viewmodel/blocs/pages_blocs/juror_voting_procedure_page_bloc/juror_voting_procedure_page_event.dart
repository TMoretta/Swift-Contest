part of 'juror_voting_procedure_page_bloc.dart';

sealed class JurorVotingProcedurePageEvent extends Equatable {
  const JurorVotingProcedurePageEvent();
}

final class JurorVotingProcedurePageFetch
    extends JurorVotingProcedurePageEvent {
  final String votingSessionId;

  const JurorVotingProcedurePageFetch({
    required this.votingSessionId,
  });

  @override
  List<Object?> get props => [votingSessionId];
}

final class JurorVotingProcedurePageSubmit extends JurorVotingProcedurePageEvent {
  final Map<VotingFormField, String> headerFieldsValues;
  final Map<VotingSessionParticipant, Map<VotingFormField, String>> participantFieldsValues;
  final Map<VotingFormField, String> footerFieldsValues;

  const JurorVotingProcedurePageSubmit({
    required this.headerFieldsValues,
    required this.participantFieldsValues,
    required this.footerFieldsValues,
  });

  @override
  List<Object?> get props => [headerFieldsValues, participantFieldsValues, footerFieldsValues];
}