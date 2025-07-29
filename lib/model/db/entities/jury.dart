import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/db/types/jury_type.dart';

class Jury extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? contestId;
  final String? votingFormId;
  final String name;
  final String? token;
  final JuryType type;

  const Jury({
    required this.id,
    required this.createdAt,
    required this.contestId,
    required this.votingFormId,
    required this.name,
    required this.token,
    required this.type,
  });

  factory Jury.fromJson(Map<String, dynamic> json) {
    return Jury(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      contestId: json['contest_id'] as String,
      votingFormId: json['voting_form_id'] as String,
      name: json['name'] as String,
      token: json['token'] as String,
      type: JuryType.values.byName(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if(contestId!=null) 'contest_id': contestId,
      if(votingFormId!=null) 'voting_form_id': votingFormId,
      'name': name,
      if(token!=null) 'token': token,
      'type': type.name,
      };
  }

  Jury copyWith({
    String? id,
    DateTime? createdAt,
    String? contestId,
    String? votingFormId,
    String? name,
    String? token,
    JuryType? type,
  }) {
    return Jury(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contestId: contestId ?? this.contestId,
      votingFormId: votingFormId ?? this.votingFormId,
      name: name ?? this.name,
      token: token ?? this.token,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    contestId,
    votingFormId,
    name,
    token,
    type,
  ];
}
