import 'package:equatable/equatable.dart';

class JurorInvitation extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? contestId;
  final String? juryId;
  final String? token;
  final String email;

  const JurorInvitation({
    required this.id,
    required this.createdAt,
    required this.contestId,
    required this.juryId,
    required this.token,
    required this.email,
  });

  factory JurorInvitation.fromJson(Map<String, dynamic> json) {
    return JurorInvitation(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      contestId: json['contest_id'] as String,
      juryId: json['jury_id'] as String,
      token: json['token'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if(contestId!=null) 'contest_id': contestId,
      if(juryId!=null) 'jury_id': juryId,
      if (token != null) 'token': token,
      'email': email,
    };
  }

  JurorInvitation copyWith({
    String? id,
    DateTime? createdAt,
    String? contestId,
    String? juryId,
    String? token,
    String? email,
  }) {
    return JurorInvitation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contestId: contestId ?? this.contestId,
      juryId: juryId ?? this.juryId,
      token: token ?? this.token,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [id, createdAt, contestId, juryId, token, email, token];
}
