part of 'organizer_voting_result_export_page_bloc.dart';

@immutable
final class OrganizerVotingResultExportPageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingResultExportPageEvent? sourceEvent;
  final String? message;
  final VotingSessionProcedureBundle? votingSessionProcedureBundle;
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
     this.votingSessionProcedureBundle,
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
    VotingSessionProcedureBundle? votingSessionProcedureBundle,
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
votingSessionProcedureBundle: votingSessionProcedureBundle ?? this.votingSessionProcedureBundle,
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
    votingSessionProcedureBundle,
    participantsVotingsPerJurorMap,
    jurorsVotingsPerParticipantMap,
    jurorsWithoutSubmissionBundles,
      ];
}
