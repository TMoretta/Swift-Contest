import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/enums/participant_status.dart';

class Participation extends Equatable {
  final String id;
  final DateTime createdAt;
  final String contestId;
  final String participantId;
  final ParticipantStatus participantStatus;
  final String invitationEmail;
  final bool hasSubmitted;

  const Participation({
    required this.id,
    required this.createdAt,
    required this.contestId,
    required this.participantId,
    required this.participantStatus,
    required this.invitationEmail,
    required this.hasSubmitted,
  });

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      contestId: json['contest_id'] as String,
      participantId: json['participant_id'] as String,
      participantStatus: ParticipantStatus.values.byName(json['participant_status'] as String),
      invitationEmail: json['invitation_email'] as String,
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
      'invitation_email': invitationEmail,
      'has_submitted': hasSubmitted,
    };
  }

  Participation copyWith({
    String? id,
    DateTime? createdAt,
    String? contestId,
    String? participantId,
    ParticipantStatus? participantStatus,
    String? invitationEmail,
    bool? hasSubmitted,
  }) {
    return Participation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contestId: contestId ?? this.contestId,
      participantId: participantId ?? this.participantId,
      participantStatus: participantStatus ?? this.participantStatus,
      invitationEmail: invitationEmail ?? this.invitationEmail,
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
        invitationEmail,
        hasSubmitted,
      ];
}

class ParticipationModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? contestId;
  final String? participantId;
  final ParticipantStatus? participantStatus;
  final String? invitationEmail;
  final bool? hasSubmitted;

  const ParticipationModel({
    this.id,
    this.createdAt,
    this.contestId,
    this.participantId,
    this.participantStatus,
    this.invitationEmail,
    this.hasSubmitted,
  });

  factory ParticipationModel.fromJson(Map<String, dynamic> json) {
    return ParticipationModel(
      id: json['id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : null,
      contestId: json['contest_id'] as String?,
      participantId: json['participant_id'] as String?,
      participantStatus: json['participant_status'] != null
          ? ParticipantStatus.values.byName(json['participant_status'] as String)
          : null,
      invitationEmail: json['invitation_email'] as String?,
      hasSubmitted: json['has_submitted'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'contest_id': contestId,
      'participant_id': participantId,
      'participant_status': participantStatus?.name,
      'invitation_email': invitationEmail,
      'has_submitted': hasSubmitted,
    };
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        contestId,
        participantId,
        participantStatus,
        invitationEmail,
        hasSubmitted,
      ];
}
