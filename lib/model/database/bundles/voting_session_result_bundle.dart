// import 'package:collection/collection.dart';
// import 'package:equatable/equatable.dart';
// import 'package:swift_contest/model/database/bundles/juror_vote_bundle.dart';
// import 'package:swift_contest/model/database/bundles/voting_session_bundle.dart';
// import 'package:swift_contest/model/database/bundles/voting_session_jury_bundle.dart';
// import 'package:swift_contest/model/database/entities/juror_vote.dart';
// import 'package:swift_contest/model/database/entities/juror_voting.dart';
// import 'package:swift_contest/model/database/entities/voting_session_exclusion.dart';
// import 'package:swift_contest/model/database/entities/voting_session_juror.dart';
// import 'package:swift_contest/model/database/entities/voting_session_participant.dart';
//
// class VotingSessionResultBundle extends Equatable {
//   final VotingSessionBundle votingSessionBundle;
//   final List<VotingSessionJuryBundle> votingSessionJuriesBundles;
//   final List<VotingSessionParticipation> votingSessionParticipations;
//   final List<VotingSessionExclusion> votingSessionExclusions;
//
//   // Strutture dati mappate per un facile accesso nella UI
//   final Map<VotingSessionJuration, Map<VotingSessionParticipation, List<JurorVoteBundle>?>>
//   participantsVotingsPerJurorMap;
//   final Map<VotingSessionParticipation, Map<VotingSessionJuration, List<JurorVoteBundle>?>>
//   jurorsVotingsPerParticipantMap;
//   final List<VotingSessionJuration> jurorsWithoutSubmission;
//
//   const VotingSessionResultBundle({
//     required this.votingSessionBundle,
//     required this.votingSessionJuriesBundles,
//     required this.votingSessionParticipations,
//     required this.votingSessionExclusions,
//     required this.participantsVotingsPerJurorMap,
//     required this.jurorsVotingsPerParticipantMap,
//     required this.jurorsWithoutSubmission,
//   });
//
//   /// Costruttore Factory che prende il JSON grezzo dalla RPC
//   /// e fa tutto il lavoro di mappatura e aggregazione.
//   factory VotingSessionResultBundle.fromRawJson(Map<String, dynamic> json) {
//     // 1. Parsing dei dati pre-aggregati dalla RPC.
//     final votingSessionBundle = VotingSessionBundle.fromJson(json['voting_session_bundle']);
//     final votingSessionParticipations = (json['voting_session_participations'] as List<dynamic>)
//         .map((e) => VotingSessionParticipation.fromJson(e))
//         .toList();
//     final votingSessionJuriesBundles = (json['voting_session_juries_bundles'] as List<dynamic>)
//         .map((e) => VotingSessionJuryBundle.fromJson(e))
//         .toList();
//     final votingSessionExclusions = (json['voting_session_exclusions'] as List<dynamic>)
//         .map((e) => VotingSessionExclusion.fromJson(e))
//         .toList();
//     final rawJurorVotings = (json['raw_jurors_votings'] as List<dynamic>)
//         .map((e) => JurorVoting.fromJson(e))
//         .toList();
//     final rawJurorVotes = (json['raw_jurors_votes'] as List<dynamic>)
//         .map((e) => JurorVote.fromJson(e))
//         .toList();
//
//     // 2. Estrazione delle liste piatte per una facile ricerca.
//     final allVotingSessionJurations =
//     votingSessionJuriesBundles.expand((b) => b.votingSessionJurations).toList();
//     final allVotingFormFields = votingSessionJuriesBundles
//         .expand((b) => b.votingFormBundle.votingFormFields)
//         .toList();
//
//     // 3. Mappatura dei voti (la parte più importante).
//     final Map<VotingSessionJuration, Map<VotingSessionParticipation, List<JurorVoteBundle>?>>
//     participantsVotingsPerJurorMap = {};
//     final List<VotingSessionJuration> jurorsWithoutSubmission = [];
//
//     for (var vsJuration in allVotingSessionJurations) {
//       if (!vsJuration.hasSubmitted) {
//         jurorsWithoutSubmission.add(vsJuration);
//         continue;
//       }
//
//       final Map<VotingSessionParticipation, List<JurorVoteBundle>?> singleJurorVotes = {};
//       for (var vsParticipation in votingSessionParticipations) {
//         final isExcluded = votingSessionExclusions.any((ex) =>
//         ex.votingSessionJurationId == vsJuration.id &&
//             ex.votingSessionParticipationId == vsParticipation.id);
//
//         if (isExcluded) {
//           singleJurorVotes[vsParticipation] = null; // null indica un'esclusione
//           continue;
//         }
//
//         final jurorVoting = rawJurorVotings.firstWhereOrNull((v) =>
//         v.votingSessionJurationId == vsJuration.id &&
//             v.votingSessionParticipationId == vsParticipation.id);
//
//         if (jurorVoting == null) {
//           // Il giurato ha sottomesso ma non per questo partecipante (caso raro, ma gestito)
//           singleJurorVotes[vsParticipation] = [];
//           continue;
//         }
//
//         final jurorVotes = rawJurorVotes.where((v) => v.jurorVotingId == jurorVoting.id).toList();
//
//         final jurorVoteBundles = jurorVotes.map((vote) {
//           return JurorVoteBundle(
//             jurorVote: vote,
//             votingFormField:
//             allVotingFormFields.firstWhere((field) => field.id == vote.votingFormFieldId),
//           );
//         }).toList();
//
//         singleJurorVotes[vsParticipation] = jurorVoteBundles;
//       }
//       participantsVotingsPerJurorMap[vsJuration] = singleJurorVotes;
//     }
//
//     // 4. Creazione della mappa inversa per un accesso più facile.
//     final Map<VotingSessionParticipation, Map<VotingSessionJuration, List<JurorVoteBundle>?>>
//     jurorsVotingsPerParticipantMap = {};
//     participantsVotingsPerJurorMap.forEach((juror, participantVotes) {
//       participantVotes.forEach((participant, votes) {
//         jurorsVotingsPerParticipantMap.putIfAbsent(participant, () => {})[juror] = votes;
//       });
//     });
//
//     return VotingSessionResultBundle(
//       votingSessionBundle: votingSessionBundle,
//       votingSessionJuriesBundles: votingSessionJuriesBundles,
//       votingSessionParticipations: votingSessionParticipations,
//       votingSessionExclusions: votingSessionExclusions,
//       participantsVotingsPerJurorMap: participantsVotingsPerJurorMap,
//       jurorsVotingsPerParticipantMap: jurorsVotingsPerParticipantMap,
//       jurorsWithoutSubmission: jurorsWithoutSubmission,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//     votingSessionBundle,
//     votingSessionJuriesBundles,
//     votingSessionParticipations,
//     votingSessionExclusions,
//     participantsVotingsPerJurorMap,
//     jurorsVotingsPerParticipantMap,
//     jurorsWithoutSubmission,
//   ];
// }