// import 'package:equatable/equatable.dart';
// import 'package:swift_contest/model/enums/voting_session_procedure_step.dart';
//
// class VotingSessionProcedure extends Equatable {
//   final String id;
//   final DateTime createdAt;
//   final String votingSessionId;
//   final VotingSessionStatus? currentStep;
//   final int? currentParticipantIndex;
//   final DateTime? currentStepDeadline;
//
//   const VotingSessionProcedure({
//     required this.id,
//     required this.createdAt,
//     required this.votingSessionId,
//     this.currentStep,
//     this.currentParticipantIndex,
//     this.currentStepDeadline,
//   });
//
//   factory VotingSessionProcedure.fromJson(Map<String, dynamic> json) {
//     return VotingSessionProcedure(
//       id: json['id'] as String,
//       createdAt: DateTime.parse(json['created_at']).toLocal(),
//       votingSessionId: json['voting_session_id'] as String,
//       currentStep: (json['current_step'] != null)
//           ? VotingSessionStatus.values.byName(json['current_step'])
//           : null,
//       currentParticipantIndex: json['current_participant_index'] as int?,
//       currentStepDeadline: (json['current_step_deadline'] != null)
//           ? DateTime.parse(json['current_step_deadline']).toLocal()
//           : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'created_at': createdAt.toUtc().toIso8601String(),
//       'voting_session_id': votingSessionId,
//       'current_step': currentStep,
//       'current_participant_index': currentParticipantIndex,
//       'current_step_deadline': currentStepDeadline?.toUtc().toIso8601String(),
//     };
//   }
//
//   Map<String, dynamic> toRpcJson() {
//     return {
//       'p_id': id,
//       'p_created_at': createdAt.toUtc().toIso8601String(),
//       'p_voting_session_id': votingSessionId,
//       'p_current_step': currentStep,
//       'p_current_participant_index': currentParticipantIndex,
//       'p_current_step_deadline': currentStepDeadline?.toUtc().toIso8601String(),
//     };
//   }
//
//   @override
//   List<Object?> get props => [id, createdAt, votingSessionId, currentStep, currentParticipantIndex, currentStepDeadline,];
// }
