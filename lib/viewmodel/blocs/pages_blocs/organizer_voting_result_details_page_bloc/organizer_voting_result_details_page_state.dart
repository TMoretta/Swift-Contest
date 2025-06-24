part of 'organizer_voting_result_details_page_bloc.dart';

final class OrganizerVotingResultDetailsPageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingResultDetailsPageEvent? sourceEvent;
  final String? message;
  final VotingSessionBundle? votingSessionBundle;
  final Map<JurationBundle, Map<ParticipationBundle, List<JurorVoteBundle>?>>?
      participantsVotingsPerJurorMap;
  final Map<ParticipationBundle, Map<JurationBundle, List<JurorVoteBundle>?>>?
      jurorsVotingsPerParticipantMap;
  final List<JurationBundle>? jurorsWithoutSubmissionBundles;
  final List<ParticipationBundle>? excludedParticipationsBundles;
  final List<JurationBundle>? excludedJurationsBundles;

  const OrganizerVotingResultDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.votingSessionBundle,
    this.jurorsWithoutSubmissionBundles,
    this.participantsVotingsPerJurorMap,
    this.jurorsVotingsPerParticipantMap,
    this.excludedParticipationsBundles,
    this.excludedJurationsBundles,
  });

  OrganizerVotingResultDetailsPageState copyWith({
    required BlocStatus status,
    OrganizerVotingResultDetailsPageEvent? sourceEvent,
    String? message,
    VotingSessionBundle? votingSessionBundle,
    Map<JurationBundle, Map<ParticipationBundle, List<JurorVoteBundle>?>>?
        participantsVotingsPerJurorMap,
    Map<ParticipationBundle, Map<JurationBundle, List<JurorVoteBundle>?>>?
        jurorsVotingsPerParticipantMap,
    List<JurationBundle>? jurorsWithoutSubmissionBundles,
  }) {
    return OrganizerVotingResultDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      votingSessionBundle: votingSessionBundle ?? this.votingSessionBundle,
      participantsVotingsPerJurorMap:
          participantsVotingsPerJurorMap ?? this.participantsVotingsPerJurorMap,
      jurorsVotingsPerParticipantMap:
          jurorsVotingsPerParticipantMap ?? this.jurorsVotingsPerParticipantMap,
      jurorsWithoutSubmissionBundles:
          jurorsWithoutSubmissionBundles ?? this.jurorsWithoutSubmissionBundles,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
        votingSessionBundle,
        participantsVotingsPerJurorMap,
        jurorsVotingsPerParticipantMap,
        jurorsWithoutSubmissionBundles,
      ];
}
