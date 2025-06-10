part of 'organizer_voting_result_export_page_bloc.dart';

@immutable
final class OrganizerVotingResultExportPageState extends Equatable {
  final BlocStatus status;
  final OrganizerVotingResultExportPageEvent? sourceEvent;
  final String? message;
  final Map<JurationBundle,
      Map<ParticipationBundle, List<JurorVoteBundle>?>>? participantsVotingsPerJurorMap;

  final Map<ParticipationBundle,
      Map<JurationBundle, List<JurorVoteBundle>?>>? jurorsVotingsPerParticipantMap;

  final List<JurationBundle>? jurorsWithoutSubmissionBundles;

  const OrganizerVotingResultExportPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.jurorsWithoutSubmissionBundles,
    this.participantsVotingsPerJurorMap,
    this.jurorsVotingsPerParticipantMap,
  });


  OrganizerVotingResultExportPageState copyWith({
    required BlocStatus status,
    OrganizerVotingResultExportPageEvent? sourceEvent,
    String? message,
    Map<JurationBundle,
        Map<ParticipationBundle, List<JurorVoteBundle>?>>? participantsVotingsPerJurorMap,
    Map<ParticipationBundle,
        Map<JurationBundle, List<JurorVoteBundle>?>>? jurorsVotingsPerParticipantMap,
    List<JurationBundle>? jurorsWithoutSubmissionBundles,
  }) {
    return OrganizerVotingResultExportPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      participantsVotingsPerJurorMap: participantsVotingsPerJurorMap ??
          this.participantsVotingsPerJurorMap,
      jurorsVotingsPerParticipantMap: jurorsVotingsPerParticipantMap ??
          this.jurorsVotingsPerParticipantMap,
      jurorsWithoutSubmissionBundles: jurorsWithoutSubmissionBundles ??
          this.jurorsWithoutSubmissionBundles,
    );
  }

  @override
  List<Object?> get props =>
      [
        status,
        sourceEvent,
        message,
        participantsVotingsPerJurorMap,
        jurorsVotingsPerParticipantMap,
        jurorsWithoutSubmissionBundles,
      ];
}
