import 'package:swift_contest/model/data_models/juration/juration_status.dart';

class Juration {
  final String id;
  final String contestId;
  final String? jurorId;
  final JurationStatus status;
  final String inviteEmail;
  final String token;

  Juration({
    required this.id,
    required this.contestId,
    this.jurorId,
    required this.status,
    required this.inviteEmail,
    required this.token,
  });

  factory Juration.fromJson(Map<String, dynamic> map) {
    return Juration(
      id: map['id'] as String,
      jurorId: map['juror_id'] as String?,
      contestId: map['contest_id'] as String,
      token: map['token'] as String,
      status: JurationStatus.values.byName(map['status']),
      inviteEmail: map['invite_email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'juror_id': jurorId,
      'contest_id': contestId,
      'token': token,
      'status': status.name,
      'invite_email': inviteEmail,
    };
  }
}
