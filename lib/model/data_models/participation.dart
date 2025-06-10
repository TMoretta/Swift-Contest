import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/enums/participant_status.dart';

class Participation extends Equatable {
  final String id;
  final DateTime createdAt;
  final String contestId;
  final String participantId;
  final ParticipantStatus participantStatus;
  final bool hasSubmitted;

  const Participation({
    required this.id,
    required this.createdAt,
    required this.contestId,
    required this.participantId,
    required this.participantStatus,
    required this.hasSubmitted,
  });

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      contestId: json['contest_id'] as String,
      participantId: json['participant_id'] as String,
      participantStatus: ParticipantStatus.values.byName(json['participant_status'] as String),
      hasSubmitted: json['has_submitted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'contest_id': contestId,
      'participant_id': participantId,
      'participant_status': participantStatus.name,
      'has_submitted': hasSubmitted,
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
      'p_contest_id': contestId,
      'p_participant_id': participantId,
      'p_participant_status': participantStatus.name,
      'p_has_submitted': hasSubmitted,
    };
  }

  Participation copyWith({
    String? id,
    DateTime? createdAt,
    String? contestId,
    String? participantId,
    ParticipantStatus? participantStatus,
    bool? hasSubmitted,
  }) {
    return Participation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contestId: contestId ?? this.contestId,
      participantId: participantId ?? this.participantId,
      participantStatus: participantStatus ?? this.participantStatus,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        contestId,
        participantId,
        participantStatus,
        hasSubmitted,
      ];
}
