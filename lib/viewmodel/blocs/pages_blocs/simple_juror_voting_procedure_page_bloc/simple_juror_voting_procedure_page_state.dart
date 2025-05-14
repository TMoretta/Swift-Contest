part of 'simple_juror_voting_procedure_page_bloc.dart';

@immutable
final class SimpleJurorVotingProcedurePageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final VotingSession? votingSession;
  final VotingSessionProcedure? votingSessionProcedure;
  final List<VotingSessionParticipant>? votingSessionParticipants;
  final List<Work>? works;
  final List<Participant>? participants;
  final List<Juror>? jurors;
  final VotingForm? votingForm;
  final List<VotingFormField>? votingFormFields;

  const SimpleJurorVotingProcedurePageState({
    required this.status,
    this.message,
    this.votingSession,
    this.votingSessionProcedure,
    this.votingSessionParticipants,
    this.works,
    this.participants,
    this.jurors,
    this.votingForm,
    this.votingFormFields,
  });

  SimpleJurorVotingProcedurePageState copyWith({
    required BlocStatus status,
    String? message,
    VotingSession? votingSession,
    VotingSessionProcedure? votingSessionProcedure,
    List<VotingSessionParticipant>? votingSessionParticipants,
    List<Work>? works,
    List<Participant>? participants,
    List<Juror>? jurors,
    VotingForm? votingForm,
    List<VotingFormField>? votingFormFields,
  }) {
    return SimpleJurorVotingProcedurePageState(
      status: status,
      message: message,
      votingSession: votingSession ?? this.votingSession,
      votingSessionProcedure:
          votingSessionProcedure ?? this.votingSessionProcedure,
      votingSessionParticipants:
          votingSessionParticipants ?? this.votingSessionParticipants,
      works: works ?? this.works,
      participants: participants ?? this.participants,
      jurors: jurors ?? this.jurors,
      votingForm: votingForm ?? this.votingForm,
      votingFormFields: votingFormFields ?? this.votingFormFields,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        votingSession,
        votingSessionProcedure,
        votingSessionParticipants,
        works,
        participants,
        jurors,
        votingForm,
        votingFormFields,
      ];
}
