import 'package:equatable/equatable.dart';

class VotingForm extends Equatable {
  final String id;
  final DateTime createdAt;

  const VotingForm({
    required this.id,
    required this.createdAt,
  });

  factory VotingForm.fromJson(Map<String, dynamic> json) {
    return VotingForm(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  VotingForm copyWith({
    String? id,
    DateTime? createdAt,
  }) {
    return VotingForm(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
    );
  }


  @override
  List<Object?> get props => [id, createdAt];
}