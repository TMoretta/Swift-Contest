import 'package:equatable/equatable.dart';

class Participation extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? contestId;
  final String? participantId;
  final String invitationEmail;
  final bool hasSubmitted;

  const Participation({
    required this.id,
    required this.createdAt,
    required this.contestId,
    required this.participantId,
    required this.invitationEmail,
    required this.hasSubmitted,
  });

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      contestId: json['contest_id'] as String,
      participantId: json['participant_id'] as String,
      invitationEmail: json['invitation_email'] as String,
      hasSubmitted: json['has_submitted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if(id!=null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if(contestId!=null) 'contest_id': contestId,
      if(participantId!=null) 'participant_id': participantId,
      'invitation_email': invitationEmail,
      'has_submitted': hasSubmitted,
    };
  }

  Participation copyWith({
    String? id,
    DateTime? createdAt,
    String? contestId,
    String? participantId,
    String? invitationEmail,
    bool? hasSubmitted,
  }) {
    return Participation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contestId: contestId ?? this.contestId,
      participantId: participantId ?? this.participantId,
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
        invitationEmail,
        hasSubmitted,
      ];
}
