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
  final Map<Juror, Map<Participant, List<JurorVote>?>>? jurorVotesPerJurorMap;
  final Map<Participant, Map<Juror, List<JurorVote>?>>? jurorVotesPerParticipantMap;
  final List<VotingFormField>? votingFormFields;
  final Map<Juror, List<Participant>>? participantsExclusionsPerJurorMap;
  final List<SimpleJuror>? simpleJurors;
  final List<SimpleJuror>? simpleJurorsThatSubmitted;
  final List<SimpleJuror>? simpleJurorsThatNotSubmitted;
  final Map<SimpleJuror, Map<Participant, List<SimpleJurorVote>>>? simpleJurorVotesPerSimpleJurorMap;
  final Map<Participant, Map<SimpleJuror, List<SimpleJurorVote>>>? simpleJurorVotesPerParticipantMap;

  const OrganizerVotingResultsPageState({
    required this.status,
    this.message,
    this.votingSession,
    this.jurors,
    this.jurorsThatSubmitted,
    this.jurorsThatNotSubmitted,
    this.participants,
    this.jurorVotesPerJurorMap,
    this.jurorVotesPerParticipantMap,
    this.votingFormFields,
    this.participantsExclusionsPerJurorMap,
    this.simpleJurors,
    this.simpleJurorsThatSubmitted,
    this.simpleJurorsThatNotSubmitted,
    this.simpleJurorVotesPerSimpleJurorMap,
    this.simpleJurorVotesPerParticipantMap,
  });

  OrganizerVotingResultsPageState copyWith({
    BlocStatus? status,
    String? message,
    VotingSession? votingSession,
    List<Juror>? jurors,
    List<Juror>? jurorsThatSubmitted,
    List<Juror>? jurorsThatNotSubmitted,
    List<Participant>? participants,
    Map<Juror, Map<Participant, List<JurorVote>?>>? jurorVotesPerJurorMap,
    Map<Participant, Map<Juror, List<JurorVote>?>>? jurorVotesPerParticipantMap,
    List<VotingFormField>? votingFormFields,
    Map<Juror, List<Participant>>? participantsExclusionsPerJurorMap,
    List<SimpleJuror>? simpleJurors,
    List<SimpleJuror>? simpleJurorsThatSubmitted,
    List<SimpleJuror>? simpleJurorsThatNotSubmitted,
    Map<SimpleJuror, Map<Participant, List<SimpleJurorVote>>>?
        simpleJurorVotesPerSimpleJurorMap,
    Map<Participant, Map<SimpleJuror, List<SimpleJurorVote>>>?
        simpleJurorVotesPerParticipantMap,
  }) {
    return OrganizerVotingResultsPageState(
      status: status ?? this.status,
      message: message ?? this.message,
      votingSession: votingSession ?? this.votingSession,
      jurors: jurors ?? this.jurors,
      jurorsThatSubmitted: jurorsThatSubmitted ?? this.jurorsThatSubmitted,
      jurorsThatNotSubmitted: jurorsThatNotSubmitted ?? this.jurorsThatNotSubmitted,
      participants: participants ?? this.participants,
      jurorVotesPerJurorMap: jurorVotesPerJurorMap ?? this.jurorVotesPerJurorMap,
      jurorVotesPerParticipantMap: jurorVotesPerParticipantMap ?? this.jurorVotesPerParticipantMap,
      votingFormFields: votingFormFields ?? this.votingFormFields,
      participantsExclusionsPerJurorMap:
          participantsExclusionsPerJurorMap ?? this.participantsExclusionsPerJurorMap,
      simpleJurors: simpleJurors ?? this.simpleJurors,
      simpleJurorsThatSubmitted: simpleJurorsThatSubmitted ?? this.simpleJurorsThatSubmitted,
      simpleJurorsThatNotSubmitted: simpleJurorsThatNotSubmitted ?? this.simpleJurorsThatNotSubmitted,
      simpleJurorVotesPerSimpleJurorMap: simpleJurorVotesPerSimpleJurorMap ?? this.simpleJurorVotesPerSimpleJurorMap,
      simpleJurorVotesPerParticipantMap: simpleJurorVotesPerParticipantMap ?? this.simpleJurorVotesPerParticipantMap,
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
        jurorVotesPerJurorMap,
    jurorVotesPerParticipantMap,
        votingFormFields,
        participantsExclusionsPerJurorMap,
        simpleJurors,
        simpleJurorsThatSubmitted,
        simpleJurorsThatNotSubmitted,
        simpleJurorVotesPerSimpleJurorMap,
        simpleJurorVotesPerParticipantMap,
      ];
}
