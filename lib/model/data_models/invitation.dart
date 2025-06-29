import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/enums/juror_status.dart';
import 'package:swift_contest/model/enums/member_role.dart';

class Invitation extends Equatable {
  final String id;
  final DateTime createdAt;
  final String contestId;
  final String token;
  final String email;
  final MemberRole memberRole;

  const Invitation({
    required this.id,
    required this.createdAt,
    required this.contestId,
    required this.token,
    required this.email,
    required this.memberRole,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      contestId: json['contest_id'] as String,
      token: json['token'] as String,
      email: json['email'] as String,
      memberRole: MemberRole.values.byName(json['member_role'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'contest_id': contestId,
      'token': token,
      'email': email,
      'member_role': memberRole.name,
    };
  }

  Invitation copyWith({
    String? id,
    DateTime? createdAt,
    String? contestId,
    String? token,
    String? email,
    MemberRole? memberRole,
  }) {
    return Invitation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contestId: contestId ?? this.contestId,
      token: token ?? this.token,
      email: email ?? this.email,
      memberRole: memberRole ?? this.memberRole,
    );
  }

  @override
  List<Object?> get props => [id, createdAt, contestId, token, email, memberRole, token];
}

class InvitationNullable extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? contestId;
  final String? token;
  final String? email;
  final MemberRole? memberRole;

  const InvitationNullable({
    this.id,
    this.createdAt,
    this.contestId,
    this.token,
    this.email,
    this.memberRole,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'contest_id': contestId,
      'token': token,
      'email': email,
      'member_role': memberRole?.name,
    };
  }

  @override
  List<Object?> get props => [id, createdAt, contestId, token, email, memberRole];
}
