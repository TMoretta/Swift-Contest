part of 'juror_voting_procedure_page_bloc.dart';

@immutable
final class JurorVotingProcedurePageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final VotingSession? votingSession;
  final VotingSessionProcedure? votingSessionProcedure;
  final List<VotingSessionParticipant>? votingSessionParticipants;
  final List<Work>? works;
  final List<VotingSessionJuror>? votingSessionJurors;
  final List<Participant>? participants;
  final List<Juror>? jurors;
  final VotingForm? votingForm;
  final List<VotingFormField>? votingFormFields;
  final List<Participant>? excludedFromParticipants;

  const JurorVotingProcedurePageState({
    required this.status,
    this.message,
    this.votingSession,
    this.votingSessionProcedure,
    this.votingSessionParticipants,
    this.works,
    this.votingSessionJurors,
    this.participants,
    this.jurors,
    this.votingForm,
    this.votingFormFields,
    this.excludedFromParticipants,
  });

  JurorVotingProcedurePageState copyWith({
    BlocStatus? status,
    String? message,
    VotingSession? votingSession,
    VotingSessionProcedure? votingSessionProcedure,
    List<VotingSessionParticipant>? votingSessionParticipants,
    List<Work>? works,
    List<VotingSessionJuror>? votingSessionJurors,
    List<Participant>? participants,
    List<Juror>? jurors,
    List<String>? excludedVotingSessionParticipantsIds,
    VotingForm? votingForm,
    List<VotingFormField>? votingFormFields,
    List<Participant>? excludedFromParticipants,
  }) {
    return JurorVotingProcedurePageState(
      status: status ?? this.status,
      message: message ?? this.message,
      votingSession: votingSession ?? this.votingSession,
      votingSessionProcedure: votingSessionProcedure ?? this.votingSessionProcedure,
      votingSessionParticipants: votingSessionParticipants ?? this.votingSessionParticipants,
      works: works ?? this.works,
      votingSessionJurors: votingSessionJurors ?? this.votingSessionJurors,
      participants: participants ?? this.participants,
      jurors: jurors ?? this.jurors,
      votingForm: votingForm ?? this.votingForm,
      votingFormFields: votingFormFields ?? this.votingFormFields,
      excludedFromParticipants: excludedFromParticipants ?? this.excludedFromParticipants,
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
        votingSessionJurors,
        participants,
        jurors,
        votingForm,
        votingFormFields,
        excludedFromParticipants,
      ];
}
