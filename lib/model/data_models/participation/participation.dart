import 'package:swift_contest/model/data_models/participation/participation_status.dart';

class Participation {
  final String id;
  final String? participantId;
  final String contestId;
  final String token;
  final ParticipationStatus status;
  final String inviteEmail;
  final String? workId;

  Participation({
    required this.id,
    this.participantId,
    required this.contestId,
    required this.token,
    required this.status,
    required this.inviteEmail,
    this.workId,
  });

  factory Participation.fromJson(Map<String, dynamic> map) {
    return Participation(
      id: map['id'] as String,
      participantId: map['participant_id'] as String?,
      contestId: map['contest_id'] as String,
      token: map['token'] as String,
      status: ParticipationStatus.values.byName(map['status']),
      inviteEmail: map['invite_email'] as String,
      workId: map['work_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_id': participantId,
      'contest_id': contestId,
      'token': token,
      'status': status.name,
      'invite_email': inviteEmail,
      'work_id': workId,
    };
  }
}
