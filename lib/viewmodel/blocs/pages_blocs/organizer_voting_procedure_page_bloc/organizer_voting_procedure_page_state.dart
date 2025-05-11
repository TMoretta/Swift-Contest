part of 'organizer_voting_procedure_page_bloc.dart';

@immutable
class OrganizerVotingProcedurePageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final VotingSession? votingSession;
  final VotingSessionProcedure? votingSessionProcedure;
  final List<VotingSessionParticipant>? votingSessionParticipants;
  final List<Work>? works;
  final List<VotingSessionJuror>? votingSessionJurors;
  final List<ParticipantAndJuror>? votingSessionExclusions;
  final List<Participant>? participants;
  final List<Juror>? jurors;
  final VotingSessionToken? votingSessionToken;

  const OrganizerVotingProcedurePageState({
    required this.status,
    this.message,
    this.votingSession,
    this.votingSessionProcedure,
    this.votingSessionParticipants,
    this.works,
    this.votingSessionJurors,
    this.votingSessionExclusions,
    this.participants,
    this.jurors,
    this.votingSessionToken,
  });

  OrganizerVotingProcedurePageState copyWith({
    BlocStatus? status,
    String? message,
    VotingSession? votingSession,
    VotingSessionProcedure? votingSessionProcedure,
    List<VotingSessionParticipant>? votingSessionParticipants,
    List<Work>? works,
    List<VotingSessionJuror>? votingSessionJurors,
    List<ParticipantAndJuror>? votingSessionExclusions,
    List<Participant>? participants,
    List<Juror>? jurors,
    VotingSessionToken? votingSessionToken,
  }) {
    return OrganizerVotingProcedurePageState(
      status: status ?? this.status,
      message: message ?? this.message,
      votingSession: votingSession ?? this.votingSession,
      votingSessionProcedure: votingSessionProcedure ?? this.votingSessionProcedure,
      votingSessionParticipants: votingSessionParticipants ?? this.votingSessionParticipants,
      works: works ?? this.works,
      votingSessionJurors: votingSessionJurors ?? this.votingSessionJurors,
      votingSessionExclusions: votingSessionExclusions ?? this.votingSessionExclusions,
      participants: participants ?? this.participants,
      jurors: jurors ?? this.jurors,
      votingSessionToken: votingSessionToken ?? this.votingSessionToken,
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
        votingSessionExclusions,
        participants,
        jurors,
        votingSessionToken,
      ];
}