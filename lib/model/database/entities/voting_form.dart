import 'package:equatable/equatable.dart';

class VotingForm extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String name;
  final String description;

  const VotingForm({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.description,
  });

  factory VotingForm.fromJson(Map<String, dynamic> json) {
    return VotingForm(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      'name': name,
      'description': description,
    };
  }

  VotingForm copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? description,
  }) {
    return VotingForm(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        name,
        description,
      ];
}
