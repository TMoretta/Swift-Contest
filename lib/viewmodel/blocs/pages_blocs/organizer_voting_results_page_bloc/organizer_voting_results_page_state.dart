part of 'organizer_voting_results_page_bloc.dart';

@immutable
final class OrganizerVotingResultsPageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final VotingSession? votingSession;
  final List<Juror>? jurors;
  final List<Juror>? jurorsThatSubmitted;
  final List<Juror>? jurorsThatNotSubmitted;
  final List<Participant>? participants;
  final Map<Juror, Map<Participant, List<Vote>?>>? votesPerJurorMap;
  final Map<Participant, Map<Juror, List<Vote>?>>? votesPerParticipantMap;
  final List<VotingFormField>? votingFormFields;
  final Map<Juror, List<Participant>>? participantsExclusionsPerJurorMap;

  const OrganizerVotingResultsPageState({
    required this.status,
    this.message,
    this.votingSession,
    this.jurors,
    this.jurorsThatSubmitted,
    this.jurorsThatNotSubmitted,
    this.participants,
    this.votesPerJurorMap,
    this.votesPerParticipantMap,
    this.votingFormFields,
    this.participantsExclusionsPerJurorMap,
  });

  OrganizerVotingResultsPageState copyWith({
    BlocStatus? status,
    String? message,
    VotingSession? votingSession,
    List<Juror>? jurors,
    List<Juror>? jurorsThatSubmitted,
    List<Juror>? jurorsThatNotSubmitted,
    List<Participant>? participants,
    Map<Juror, Map<Participant, List<Vote>?>>? votesPerJurorMap,
    Map<Participant, Map<Juror, List<Vote>?>>? votesPerParticipantMap,
    List<VotingFormField>? votingFormFields,
    Map<Juror, List<Participant>>? participantsExclusionsPerJurorMap,
  }) {
    return OrganizerVotingResultsPageState(
      status: status ?? this.status,
      message: message ?? this.message,
      votingSession: votingSession ?? this.votingSession,
      jurors: jurors ?? this.jurors,
      jurorsThatSubmitted: jurorsThatSubmitted ?? this.jurorsThatSubmitted,
      jurorsThatNotSubmitted: jurorsThatNotSubmitted ?? this.jurorsThatNotSubmitted,
      participants: participants ?? this.participants,
      votesPerJurorMap: votesPerJurorMap ?? this.votesPerJurorMap,
      votesPerParticipantMap: votesPerParticipantMap ?? this.votesPerParticipantMap,
      votingFormFields: votingFormFields ?? this.votingFormFields,
      participantsExclusionsPerJurorMap:
          participantsExclusionsPerJurorMap ?? this.participantsExclusionsPerJurorMap,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        votingSession,
        jurors,
        jurorsThatSubmitted,
        jurorsThatNotSubmitted,
        participants,
        votesPerJurorMap,
        votesPerParticipantMap,
        votingFormFields,
        participantsExclusionsPerJurorMap,
      ];
}
