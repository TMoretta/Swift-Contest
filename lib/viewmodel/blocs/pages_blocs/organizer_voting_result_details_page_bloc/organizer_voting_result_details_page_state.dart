part of 'organizer_voting_result_details_page_bloc.dart';

final class OrganizerVotingResultDetailsPageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingResultDetailsPageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final VotingSessionResultBundle? votingSessionResultBundle;
  // final Map<JurationBundle, Map<ParticipationBundle, List<JurorVoteBundle>?>>?
  //     participantsVotingsPerJurorMap;
  // final Map<ParticipationBundle, Map<JurationBundle, List<JurorVoteBundle>?>>?
  //     jurorsVotingsPerParticipantMap;
  // final List<JurationBundle>? jurorsWithoutSubmissionBundles;

  const OrganizerVotingResultDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.votingSessionResultBundle,
    // this.jurorsWithoutSubmissionBundles,
    // this.participantsVotingsPerJurorMap,
    // this.jurorsVotingsPerParticipantMap,
  });

  OrganizerVotingResultDetailsPageState copyWith({
    required BlocStatus status,
    OrganizerVotingResultDetailsPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    VotingSessionResultBundle? votingSessionResultBundle,
    // Map<JurationBundle, Map<ParticipationBundle, List<JurorVoteBundle>?>>?
    //     participantsVotingsPerJurorMap,
    // Map<ParticipationBundle, Map<JurationBundle, List<JurorVoteBundle>?>>?
    //     jurorsVotingsPerParticipantMap,
    // List<JurationBundle>? jurorsWithoutSubmissionBundles,
  }) {
    return OrganizerVotingResultDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      votingSessionResultBundle: votingSessionResultBundle ?? this.votingSessionResultBundle,
      // participantsVotingsPerJurorMap:
      //     participantsVotingsPerJurorMap ?? this.participantsVotingsPerJurorMap,
      // jurorsVotingsPerParticipantMap:
      //     jurorsVotingsPerParticipantMap ?? this.jurorsVotingsPerParticipantMap,
      // jurorsWithoutSubmissionBundles:
      //     jurorsWithoutSubmissionBundles ?? this.jurorsWithoutSubmissionBundles,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        votingSessionResultBundle,
        // participantsVotingsPerJurorMap,
        // jurorsVotingsPerParticipantMap,
        // jurorsWithoutSubmissionBundles,
      ];
}
