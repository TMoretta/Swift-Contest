import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/enums/juror_status.dart';

class Juration extends Equatable {
  final String id;
  final DateTime createdAt;
  final String contestId;
  final String jurorId;
  final JurorStatus jurorStatus;
  final String invitationEmail;

  const Juration({
    required this.id,
    required this.createdAt,
    required this.contestId,
    required this.jurorId,
    required this.jurorStatus,
    required this.invitationEmail,
  });

  factory Juration.fromJson(Map<String, dynamic> json) {
    return Juration(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      contestId: json['contest_id'] as String,
      jurorId: json['juror_id'] as String,
      jurorStatus: JurorStatus.values.byName(json['juror_status'] as String),
      invitationEmail: json['invitation_email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'contest_id': contestId,
      'juror_id': jurorId,
      'juror_status': jurorStatus.name,
      'invitation_email': invitationEmail,
    };
  }

  Juration copyWith({
    String? id,
    DateTime? createdAt,
    String? contestId,
    String? jurorId,
    JurorStatus? jurorStatus,
    String? invitationEmail,
  }) {
    return Juration(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contestId: contestId ?? this.contestId,
      jurorId: jurorId ?? this.jurorId,
      jurorStatus: jurorStatus ?? this.jurorStatus,
      invitationEmail: invitationEmail ?? this.invitationEmail,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        contestId,
        jurorId,
        jurorStatus,
        invitationEmail,
      ];
}

class JurationModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? contestId;
  final String? jurorId;
  final JurorStatus? jurorStatus;
  final String? invitationEmail;

  const JurationModel({
    this.id,
    this.createdAt,
    this.contestId,
    this.jurorId,
    this.jurorStatus,
    this.invitationEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'contest_id': contestId,
      'juror_id': jurorId,
      'juror_status': jurorStatus?.name,
      'invitation_email': invitationEmail,
    };
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        contestId,
        jurorId,
        jurorStatus,
        invitationEmail,
      ];
}
