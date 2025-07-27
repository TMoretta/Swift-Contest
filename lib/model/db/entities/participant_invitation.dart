import 'package:equatable/equatable.dart';

class ParticipantInvitation extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? contestId;
  final String? token;
  final String email;

  const ParticipantInvitation({
    required this.id,
    required this.createdAt,
    required this.contestId,
    required this.token,
    required this.email,
  });

  factory ParticipantInvitation.fromJson(Map<String, dynamic> json) {
    return ParticipantInvitation(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      contestId: json['contest_id'] as String,
      token: json['token'] as String,
      email: json['email'] as String,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      if (id != null)
        'id': id,
      if (createdAt != null)
        'created_at': createdAt!.toUtc().toIso8601String(),
      if(contestId!=null) 'contest_id': contestId,
      if (token != null)
        'token': token,
      'email': email,
    };
  }

  ParticipantInvitation copyWith({
    String? id,
    DateTime? createdAt,
    String? contestId,
    String? token,
    String? email,
  }) {
    return ParticipantInvitation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contestId: contestId ?? this.contestId,
      token: token ?? this.token,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [id, createdAt, contestId, token, email, token];
}
