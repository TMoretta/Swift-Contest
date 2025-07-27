import 'package:equatable/equatable.dart';

class Jury extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? contestId;
  final String? votingFormId;
  final String name;

  const Jury({
    required this.id,
    required this.createdAt,
    required this.contestId,
    required this.votingFormId,
    required this.name,
  });

  factory Jury.fromJson(Map<String, dynamic> json) {
    return Jury(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      contestId: json['contest_id'] as String,
      votingFormId: json['voting_form_id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if(contestId!=null) 'contest_id': contestId,
      if(votingFormId!=null) 'voting_form_id': votingFormId,
      'name': name,
      };
  }

  Jury copyWith({
    String? id,
    DateTime? createdAt,
    String? contestId,
    String? votingFormId,
    String? name,
  }) {
    return Jury(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contestId: contestId ?? this.contestId,
      votingFormId: votingFormId ?? this.votingFormId,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    contestId,
    votingFormId,
    name,
  ];
}
