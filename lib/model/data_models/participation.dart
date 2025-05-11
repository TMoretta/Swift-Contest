import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/enums/participant_status.dart';
import 'package:swift_contest/model/enums/work_status.dart';

class Participation extends Equatable {
  final String id;
  final DateTime createdAt;
  final String contestId;
  final String participantId;
  final ParticipantStatus participantStatus;
  final WorkStatus workStatus;

  const Participation({
    required this.id,
    required this.createdAt,
    required this.contestId,
    required this.participantId,
    required this.participantStatus,
    required this.workStatus,
  });

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      contestId: json['contest_id'] as String,
      participantId: json['participant_id'] as String,
      participantStatus: ParticipantStatus.values.byName(json['participant_status'] as String),
      workStatus: WorkStatus.values.byName(json['work_status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'contest_id': contestId,
      'participant_id': participantId,
      'participant_status': participantStatus.name,
      'work_status': workStatus.name,
    };
  }

  Participation copyWith({
    String? id,
    DateTime? createdAt,
    String? contestId,
    String? participantId,
    ParticipantStatus? participantStatus,
    WorkStatus? workStatus,
  }) {
    return Participation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contestId: contestId ?? this.contestId,
      participantId: participantId ?? this.participantId,
      participantStatus: participantStatus ?? this.participantStatus,
      workStatus: workStatus ?? this.workStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        contestId,
        participantId,
        participantStatus,
        workStatus,
      ];
}
