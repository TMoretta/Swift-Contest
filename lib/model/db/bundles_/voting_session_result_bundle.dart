// import 'package:equatable/equatable.dart';
// import 'package:swift_contest/model/db/bundles/juration_bundle.dart';
// import 'package:swift_contest/model/db/bundles/juror_vote_bundle.dart';
// import 'package:swift_contest/model/db/bundles/simple_juror_vote_bundle.dart';
// import 'package:swift_contest/model/bundles/voting_form_bundle.dart';
// import 'package:swift_contest/model/db/bundles/voting_session_bundle.dart';
// import 'package:swift_contest/model/db/bundles/voting_session_juration_bundle.dart';
// import 'package:swift_contest/model/db/bundles/voting_session_participation_bundle.dart';
// import 'package:swift_contest/model/db/bundles/voting_session_simple_juror_bundle.dart';
// import 'package:swift_contest/model/data_models/juration.dart';
// import 'package:swift_contest/model/data_models/juror_vote.dart';
// import 'package:swift_contest/model/data_models/juror_voting.dart';
// import 'package:swift_contest/model/data_models/participation.dart';
// import 'package:swift_contest/model/data_models/place.dart';
// import 'package:swift_contest/model/data_models/profile.dart';
// import 'package:swift_contest/model/data_models/simple_juror.dart';
// import 'package:swift_contest/model/data_models/simple_juror_vote.dart';
// import 'package:swift_contest/model/data_models/simple_juror_voting.dart';
// import 'package:swift_contest/model/data_models/voting_form.dart';
// import 'package:swift_contest/model/data_models/voting_session.dart';
// import 'package:swift_contest/model/data_models/voting_session_exclusion.dart';
// import 'package:swift_contest/model/data_models/voting_session_juration.dart';
// import 'package:swift_contest/model/data_models/voting_session_participation.dart';
// import 'package:swift_contest/model/data_models/voting_session_simple_juror.dart';
// import 'package:swift_contest/model/data_models/work.dart';
//
// import '../../data_models/voting_form_field.dart';
// import '../bundles/participation_bundle.dart';
//
// class VotingSessionResultBundle extends Equatable {
//   final VotingSessionBundle votingSessionBundle;
//   final VotingFormBundle votingFormBundle;
//   final List<VotingSessionParticipationBundle> votingSessionParticipationsBundles;
//   final List<VotingSessionJurationBundle> votingSessionJurationsBundles;
//   final List<VotingSessionExclusion> votingSessionExclusions;
//   final List<VotingSessionSimpleJurorBundle> votingSessionSimpleJurorsBundles;
//   final Map<JurationBundle, Map<ParticipationBundle, List<JurorVoteBundle>?>>
//       participantsVotingsPerJurorMap;
//   final Map<ParticipationBundle, Map<JurationBundle, List<JurorVoteBundle>?>>
//       jurorsVotingsPerParticipantMap;
//   final Map<SimpleJuror, Map<ParticipationBundle, List<SimpleJurorVoteBundle>?>>
//       participantsVotingsPerSimpleJurorMap;
//   final Map<ParticipationBundle, Map<SimpleJuror, List<SimpleJurorVoteBundle>?>>
//       simpleJurorsVotingsPerParticipantMap;
//   final List<JurationBundle> jurorsWithoutSubmission;
//   final List<SimpleJuror> simpleJurorsWithoutSubmission;
//
//   const VotingSessionResultBundle({
//     required this.votingSessionBundle,
//     required this.votingFormBundle,
//     required this.votingSessionParticipationsBundles,
//     required this.votingSessionJurationsBundles,
//     required this.votingSessionExclusions,
//     required this.votingSessionSimpleJurorsBundles,
//     required this.participantsVotingsPerJurorMap,
//     required this.jurorsVotingsPerParticipantMap,
//     required this.participantsVotingsPerSimpleJurorMap,
//     required this.simpleJurorsVotingsPerParticipantMap,
//     required this.jurorsWithoutSubmission,
//     required this.simpleJurorsWithoutSubmission,
//   });
//
//   factory VotingSessionResultBundle.fromRpcJson(Map<String, dynamic> json) {
//     final List<Participation> participations = (json['participations'] as List<dynamic>)
//         .map((e) => Participation.fromJson(e))
//         .toList(growable: false);
//     final List<Participant> participants = (json['participants'] as List<dynamic>)
//         .map((e) => Participant.fromJson(e))
//         .toList(growable: false);
//     final List<Work> works =
//         (json['works'] as List<dynamic>).map((e) => Work.fromJson(e)).toList(growable: false);
//     final List<Juration> jurations = (json['jurations'] as List<dynamic>)
//         .map((e) => Juration.fromJson(e))
//         .toList(growable: false);
//     final List<Juror> jurors =
//         (json['jurors'] as List<dynamic>).map((e) => Juror.fromJson(e)).toList(growable: false);
//     final VotingForm votingForm = VotingForm.fromJson(json['voting_form']);
//     final List<VotingFormField> votingFormFields = (json['voting_form_fields'] as List<dynamic>)
//         .map((e) => VotingFormField.fromJson(e))
//         .toList(growable: false);
//     votingFormFields.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
//     final VotingSession votingSession = VotingSession.fromJson(json['voting_session']);
//     final Place? geoResPlace =
//         (json['geo_res_place'] != null) ? Place.fromJson(json['geo_res_place']) : null;
//     final votingSessionBundle =
//         VotingSessionBundle(votingSession: votingSession, geoResPlace: geoResPlace);
//     final List<VotingSessionParticipation> votingSessionParticipations =
//         (json['voting_session_participations'] as List<dynamic>)
//             .map((e) => VotingSessionParticipation.fromJson(e))
//             .toList(growable: false);
//     final List<VotingSessionJuration> votingSessionJurations =
//         (json['voting_session_jurations'] as List<dynamic>)
//             .map((e) => VotingSessionJuration.fromJson(e))
//             .toList(growable: false);
//     final List<VotingSessionExclusion> votingSessionExclusions =
//         (json['voting_session_exclusions'] as List<dynamic>)
//             .map((e) => VotingSessionExclusion.fromJson(e))
//             .toList(growable: false);
//     final List<VotingSessionSimpleJuror> votingSessionSimpleJurors =
//         (json['voting_session_simple_jurors'] as List<dynamic>)
//             .map((e) => VotingSessionSimpleJuror.fromJson(e))
//             .toList(growable: false);
//     final List<SimpleJuror> simpleJurors = (json['simple_jurors'] as List<dynamic>)
//         .map((e) => SimpleJuror.fromJson(e))
//         .toList(growable: false);
//
//     final votingSessionSimpleJurorsBundles =
//         votingSessionSimpleJurors.map((votingSessionSimpleJuror) {
//       final simpleJuror = simpleJurors
//           .firstWhere((simpleJuror) => simpleJuror.id == votingSessionSimpleJuror.simpleJurorId);
//       return VotingSessionSimpleJurorBundle(
//           votingSessionSimpleJuror: votingSessionSimpleJuror, simpleJuror: simpleJuror);
//     }).toList(growable: false);
//
//     final participationsBundles = participations.map((participation) {
//       final participant =
//           participants.firstWhere((participant) => participant.id == participation.participantId);
//       final work = works.where((work) => work.participationId == participation.id).firstOrNull;
//       return ParticipationBundle(
//           participation: participation, participant: participant, work: work);
//     }).toList(growable: false);
//
//     final jurationsBundles = jurations.map((juration) {
//       final juror = jurors.firstWhere((juror) => juror.id == juration.jurorId);
//       return JurationBundle(juration: juration, juror: juror);
//     }).toList(growable: false);
//
//     final votingFormBundle =
//         VotingFormBundle(votingForm: votingForm, votingFormFields: votingFormFields);
//
//     final List<VotingSessionParticipationBundle> votingSessionParticipationsBundles =
//         votingSessionParticipations.map((votingSessionParticipation) {
//       final participationBundle = participationsBundles
//           .firstWhere((e) => e.participation.id == votingSessionParticipation.participationId);
//       return VotingSessionParticipationBundle(
//         votingSessionParticipation: votingSessionParticipation,
//         participationBundle: participationBundle,
//       );
//     }).toList(growable: false);
//
//     final List<VotingSessionJurationBundle> votingSessionJurationsBundles =
//         votingSessionJurations.map((votingSessionJuration) {
//       final jurationBundle =
//           jurationsBundles.firstWhere((e) => e.juration.id == votingSessionJuration.jurationId);
//       return VotingSessionJurationBundle(
//         votingSessionJuration: votingSessionJuration,
//         jurationBundle: jurationBundle,
//       );
//     }).toList(growable: false);
//
//     final rawJurorVotings = (json['raw_jurors_votings'] as List<dynamic>)
//         .map((e) => JurorVoting.fromJson(e))
//         .toList(growable: false);
//
//     final rawJurorVotes = (json['raw_jurors_votes'] as List<dynamic>)
//         .map((e) => JurorVote.fromJson(e))
//         .toList(growable: false);
//
//     //*Parsing votes
//     final Map<JurationBundle, Map<ParticipationBundle, List<JurorVoteBundle>?>>
//         participantsVotingsPerJurorMap = {};
//     final List<JurationBundle> jurorsWithoutSubmission = [];
//     final includedVotingSessionJurationsBundles = votingSessionJurationsBundles
//         .where((e) => !e.votingSessionJuration.isExcluded)
//         .toList(growable: false);
//     final includedVotingSessionParticipationsBundles = votingSessionParticipationsBundles
//         .where((e) => !e.votingSessionParticipation.isExcluded)
//         .toList(growable: false);
//     for (var includedVotingSessionJurationBundle in includedVotingSessionJurationsBundles) {
//       final votingSessionJuration = includedVotingSessionJurationBundle.votingSessionJuration;
//       final jurationBundle = includedVotingSessionJurationBundle.jurationBundle;
//       if (!votingSessionJuration.hasSubmitted) {
//         jurorsWithoutSubmission.add(jurationBundle);
//         continue;
//       }
//
//       final Map<ParticipationBundle, List<JurorVoteBundle>?> participantsVotes = {};
//       for (var includedVotingSessionParticipationBundle
//           in includedVotingSessionParticipationsBundles) {
//         final votingSessionParticipation =
//             includedVotingSessionParticipationBundle.votingSessionParticipation;
//         final participationBundle = includedVotingSessionParticipationBundle.participationBundle;
//
//         //* Se il giurato era escluso lo aggiungo come giurato escluso per il determinato partecipante
//         final exclusion = votingSessionExclusions
//             .where((e) =>
//                 e.votingSessionParticipationId == votingSessionParticipation.id &&
//                 e.votingSessionJurationId == votingSessionJuration.id)
//             .firstOrNull;
//         if (exclusion != null) {
//           participantsVotes.addAll({participationBundle: null});
//           continue;
//         }
//
//         final jurorVoting = rawJurorVotings
//             .where((e) =>
//                 e.votingSessionJurationId == votingSessionJuration.id &&
//                 e.votingSessionParticipationId == votingSessionParticipation.id)
//             .first;
//
//         final jurorVotes =
//             rawJurorVotes.where((e) => e.jurorVotingId == jurorVoting.id).toList(growable: false);
//
//         final List<JurorVoteBundle> jurorVotesBundles = [];
//         for (var jurorVote in jurorVotes) {
//           jurorVotesBundles.add(JurorVoteBundle(
//               jurorVote: jurorVote,
//               votingFormField: votingFormBundle.votingFormFields
//                   .where((e) => e.id == jurorVote.votingFormFieldId)
//                   .first));
//         }
//
//         jurorVotesBundles
//             .sort((a, b) => a.votingFormField.orderIndex.compareTo(b.votingFormField.orderIndex));
//         participantsVotes.addAll({participationBundle: jurorVotesBundles});
//       }
//       participantsVotingsPerJurorMap.addAll({jurationBundle: participantsVotes});
//     }
//
//     //* Ottengo i voti ricevuti dai singoli partecipanti dai giurati
//     final Map<ParticipationBundle, Map<JurationBundle, List<JurorVoteBundle>?>> jurorsVotingsPerParticipantMap = {};
//     for (final jurorEntry in participantsVotingsPerJurorMap.entries) {
//       final jurationBundle = jurorEntry.key;
//       final participantsVotes = jurorEntry.value;
//
//       for (final participantEntry in participantsVotes.entries) {
//         final participationBundle = participantEntry.key;
//         final votes = participantEntry.value;
//
//         jurorsVotingsPerParticipantMap
//             .putIfAbsent(participationBundle, () => {})
//             .addAll({jurationBundle: votes});
//       }
//     }
//
//     final rawSimpleJurorVotings = (json['raw_simple_jurors_votings'] as List<dynamic>)
//         .map((e) => SimpleJurorVoting.fromJson(e))
//         .toList(growable: false);
//     final rawSimpleJurorVotes = (json['raw_simple_jurors_votes'] as List<dynamic>)
//         .map((e) => SimpleJurorVote.fromJson(e))
//         .toList(growable: false);
//
//     //*Parsing votes
//     final Map<SimpleJuror, Map<ParticipationBundle, List<SimpleJurorVoteBundle>?>>
//         participantsVotingsPerSimpleJurorMap = {};
//     final List<SimpleJuror> simpleJurorsWithoutSubmission = [];
//     for (var votingSessionSimpleJurorBundle in votingSessionSimpleJurorsBundles) {
//       final votingSessionSimpleJuror = votingSessionSimpleJurorBundle.votingSessionSimpleJuror;
//       final simpleJuror = votingSessionSimpleJurorBundle.simpleJuror;
//       if (!votingSessionSimpleJuror.hasSubmitted) {
//         simpleJurorsWithoutSubmission.add(simpleJuror);
//         continue;
//       }
//
//       final Map<ParticipationBundle, List<SimpleJurorVoteBundle>?> participantsVotes = {};
//       for (var includedVotingSessionParticipationBundle in includedVotingSessionParticipationsBundles) {
//         final votingSessionParticipation =
//             includedVotingSessionParticipationBundle.votingSessionParticipation;
//         final participationBundle = includedVotingSessionParticipationBundle.participationBundle;
//
//         final simpleJurorVoting = rawSimpleJurorVotings
//             .where((e) =>
//                 e.votingSessionSimpleJurorId == votingSessionSimpleJuror.id &&
//                 e.votingSessionParticipationId == votingSessionParticipation.id)
//             .first;
//
//         final simpleJurorVotes = rawSimpleJurorVotes
//             .where((e) => e.simpleJurorVotingId == simpleJurorVoting.id)
//             .toList(growable: false);
//
//         final List<SimpleJurorVoteBundle> simpleJurorVotesBundles = [];
//         for (var simpleJurorVote in simpleJurorVotes) {
//           simpleJurorVotesBundles.add(SimpleJurorVoteBundle(
//               simpleJurorVote: simpleJurorVote,
//               votingFormField: votingFormBundle.votingFormFields
//                   .where((e) => e.id == simpleJurorVote.votingFormFieldId)
//                   .first));
//         }
//
//         simpleJurorVotesBundles
//             .sort((a, b) => a.votingFormField.orderIndex.compareTo(b.votingFormField.orderIndex));
//         participantsVotes.addAll({participationBundle: simpleJurorVotesBundles});
//       }
//       participantsVotingsPerSimpleJurorMap.addAll({simpleJuror: participantsVotes});
//     }
//
//     //* Ottengo i voti ricevuti dai singoli partecipanti dai giurati
//     final Map<ParticipationBundle, Map<SimpleJuror, List<SimpleJurorVoteBundle>?>>
//         simpleJurorsVotingsPerParticipantMap = {};
//     for (final simpleJurorEntry in participantsVotingsPerSimpleJurorMap.entries) {
//       final simpleJuror = simpleJurorEntry.key;
//       final participantsVotes = simpleJurorEntry.value;
//
//       for (final participantEntry in participantsVotes.entries) {
//         final participationBundle = participantEntry.key;
//         final votes = participantEntry.value;
//
//         simpleJurorsVotingsPerParticipantMap
//             .putIfAbsent(participationBundle, () => {})
//             .addAll({simpleJuror: votes});
//       }
//     }
//
//     return VotingSessionResultBundle(
//       votingSessionBundle: votingSessionBundle,
//       votingFormBundle: votingFormBundle,
//       votingSessionParticipationsBundles: votingSessionParticipationsBundles,
//       votingSessionJurationsBundles: votingSessionJurationsBundles,
//       votingSessionExclusions: votingSessionExclusions,
//       votingSessionSimpleJurorsBundles: votingSessionSimpleJurorsBundles,
//       participantsVotingsPerJurorMap: participantsVotingsPerJurorMap,
//       jurorsVotingsPerParticipantMap: jurorsVotingsPerParticipantMap,
//       participantsVotingsPerSimpleJurorMap: participantsVotingsPerSimpleJurorMap,
//       simpleJurorsVotingsPerParticipantMap: simpleJurorsVotingsPerParticipantMap,
//       jurorsWithoutSubmission: jurorsWithoutSubmission,
//       simpleJurorsWithoutSubmission: simpleJurorsWithoutSubmission,
//     );
//   }
//
//   // factory VotingSessionResultBundle.fromJson(Map<String, dynamic> json) {
//   //   return VotingSessionResultBundle(
//   //     votingSessionBundle: VotingSessionBundle.fromJson(json['voting_session_bundle']),
//   //     votingFormBundle: VotingFormBundle.fromJson(json['voting_form_bundle']),
//   //     votingSessionParticipationsBundles:
//   //         (json['voting_session_participations_bundles'] as List<dynamic>)
//   //             .map((e) => VotingSessionParticipationBundle.fromJson(e))
//   //             .toList(growable: false),
//   //     votingSessionJurationsBundles: (json['voting_session_jurations_bundles'] as List<dynamic>)
//   //         .map((e) => VotingSessionJurationBundle.fromJson(e))
//   //         .toList(growable: false),
//   //     votingSessionExclusions: (json['voting_session_exclusions'] as List<dynamic>)
//   //         .map((e) => VotingSessionExclusion.fromJson(e))
//   //         .toList(growable: false),
//   //     votingSessionSimpleJurorsBundles:
//   //         (json['voting_session_simple_jurors_bundles'] as List<dynamic>)
//   //             .map((e) => VotingSessionSimpleJurorBundle.fromJson(e))
//   //             .toList(growable: false),
//   //
//   //   );
//   // }
//   //
//   // Map<String, dynamic> toJson() {
//   //   return {
//   //     'voting_session': votingSessionBundle.toJson(),
//   //     'voting_form_bundle': votingFormBundle.toJson(),
//   //     'voting_session_participations_bundles':
//   //         votingSessionParticipationsBundles.map((e) => e.toJson()).toList(),
//   //     'voting_session_jurations_bundles':
//   //         votingSessionJurationsBundles.map((e) => e.toJson()).toList(),
//   //     'voting_session_exclusions': votingSessionExclusions.map((e) => e.toJson()).toList(),
//   //     'voting_session_simple_jurors_bundles':
//   //         votingSessionSimpleJurorsBundles.map((e) => e.toJson()).toList(),
//   //   };
//   // }
//
//   VotingSessionResultBundle copyWith({
//     VotingSessionBundle? votingSessionBundle,
//     VotingFormBundle? votingFormBundle,
//     List<VotingSessionParticipationBundle>? votingSessionParticipationsBundles,
//     List<VotingSessionJurationBundle>? votingSessionJurationsBundles,
//     List<VotingSessionExclusion>? votingSessionExclusions,
//     List<VotingSessionSimpleJurorBundle>? votingSessionSimpleJurorsBundles,
//     Map<JurationBundle, Map<ParticipationBundle, List<JurorVoteBundle>?>>?
//         participantsVotingsPerJurorMap,
//     Map<ParticipationBundle, Map<JurationBundle, List<JurorVoteBundle>?>>?
//         jurorsVotingsPerParticipantMap,
//     Map<SimpleJuror, Map<ParticipationBundle, List<SimpleJurorVoteBundle>?>>?
//         participantsVotingsPerSimpleJurorMap,
//     Map<ParticipationBundle, Map<SimpleJuror, List<SimpleJurorVoteBundle>?>>?
//         simpleJurorsVotingsPerParticipantMap,
//     List<JurationBundle>? jurorsWithoutSubmission,
//     List<SimpleJuror>? simpleJurorsWithoutSubmission,
//   }) {
//     return VotingSessionResultBundle(
//       votingSessionBundle: votingSessionBundle ?? this.votingSessionBundle,
//       votingFormBundle: votingFormBundle ?? this.votingFormBundle,
//       votingSessionParticipationsBundles:
//           votingSessionParticipationsBundles ?? this.votingSessionParticipationsBundles,
//       votingSessionJurationsBundles:
//           votingSessionJurationsBundles ?? this.votingSessionJurationsBundles,
//       votingSessionExclusions: votingSessionExclusions ?? this.votingSessionExclusions,
//       votingSessionSimpleJurorsBundles:
//           votingSessionSimpleJurorsBundles ?? this.votingSessionSimpleJurorsBundles,
//       participantsVotingsPerJurorMap:
//           participantsVotingsPerJurorMap ?? this.participantsVotingsPerJurorMap,
//       jurorsVotingsPerParticipantMap:
//           jurorsVotingsPerParticipantMap ?? this.jurorsVotingsPerParticipantMap,
//       participantsVotingsPerSimpleJurorMap:
//           participantsVotingsPerSimpleJurorMap ?? this.participantsVotingsPerSimpleJurorMap,
//       simpleJurorsVotingsPerParticipantMap:
//           simpleJurorsVotingsPerParticipantMap ?? this.simpleJurorsVotingsPerParticipantMap,
//       jurorsWithoutSubmission: jurorsWithoutSubmission ?? this.jurorsWithoutSubmission,
//       simpleJurorsWithoutSubmission:
//           simpleJurorsWithoutSubmission ?? this.simpleJurorsWithoutSubmission,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//         votingSessionBundle,
//         votingFormBundle,
//         votingSessionParticipationsBundles,
//         votingSessionJurationsBundles,
//         votingSessionExclusions,
//         votingSessionSimpleJurorsBundles,
//         participantsVotingsPerJurorMap,
//         jurorsVotingsPerParticipantMap,
//         participantsVotingsPerSimpleJurorMap,
//         simpleJurorsVotingsPerParticipantMap,
//         jurorsWithoutSubmission,
//         simpleJurorsWithoutSubmission,
//       ];
// }
