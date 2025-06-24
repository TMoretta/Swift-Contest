part of 'organizer_voting_result_export_page_bloc.dart';

@immutable
final class OrganizerVotingResultExportPageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingResultExportPageEvent? sourceEvent;
  final String? message;
  final VotingSessionBundle? votingSessionBundle;
  final Map<JurationBundle, Map<ParticipationBundle, List<JurorVoteBundle>?>>?
      participantsVotingsPerJurorMap;
  final Map<ParticipationBundle, Map<JurationBundle, List<JurorVoteBundle>?>>?
      jurorsVotingsPerParticipantMap;
  final List<JurationBundle>? jurorsWithoutSubmissionBundles;
  final List<ParticipationBundle>? excludedParticipationsBundles;
  final List<JurationBundle>? excludedJurationsBundles;

  const OrganizerVotingResultExportPageState({
    required this.status,
     this.sourceEvent,
     this.message,
     this.votingSessionBundle,
     this.participantsVotingsPerJurorMap,
     this.jurorsVotingsPerParticipantMap,
     this.jurorsWithoutSubmissionBundles,
     this.excludedParticipationsBundles,
     this.excludedJurationsBundles,
  });

  OrganizerVotingResultExportPageState copyWith({
    required BlocStatus status,
    OrganizerVotingResultExportPageEvent? sourceEvent,
    String? message,
    VotingSessionBundle? votingSessionBundle,
    Map<JurationBundle, Map<ParticipationBundle, List<JurorVoteBundle>?>>?
    participantsVotingsPerJurorMap,
    Map<ParticipationBundle, Map<JurationBundle, List<JurorVoteBundle>?>>?
    jurorsVotingsPerParticipantMap,
    List<JurationBundle>? jurorsWithoutSubmissionBundles,
  }) {
    return OrganizerVotingResultExportPageState(
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
