import 'package:equatable/equatable.dart';

class Juration extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? contestId;
  final String? juryId;
  final String? jurorId;
  final String invitationEmail;

  const Juration({
    required this.id,
    required this.createdAt,
    required this.contestId,
    required this.juryId,
    required this.jurorId,
    required this.invitationEmail,
  });

  factory Juration.fromJson(Map<String, dynamic> json) {
    return Juration(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      contestId: json['contest_id'] as String,
      juryId: json['jury_id'] as String,
      jurorId: json['juror_id'] as String,
      invitationEmail: json['invitation_email'] as String,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if(contestId!=null) 'contest_id': contestId,
      if(juryId!=null) 'jury_id': juryId,
      if(jurorId!=null) 'juror_id': jurorId,
      'invitation_email': invitationEmail,
    };
  }

  Juration copyWith({
    String? id,
    DateTime? createdAt,
    String? contestId,
    String? juryId,
    String? jurorId,
    String? invitationEmail,
  }) {
    return Juration(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contestId: contestId ?? this.contestId,
      juryId: juryId ?? this.juryId,
      jurorId: jurorId ?? this.jurorId,
      invitationEmail: invitationEmail ?? this.invitationEmail,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        contestId,
        juryId,
        jurorId,
        invitationEmail,
      ];
}
