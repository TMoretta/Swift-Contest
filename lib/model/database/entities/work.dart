import 'package:equatable/equatable.dart';

class Work extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? participationId;
  final String name;
  final String description;
  final List<String> imagesPaths;

  const Work({
    required this.id,
    required this.createdAt,
    required this.participationId,
    required this.name,
    required this.description,
    required this.imagesPaths,
  });

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      participationId: json['participation_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imagesPaths: List<String>.from(json['images_paths']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if(id!=null) 'id': id,
      if(createdAt!=null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if(participationId!=null) 'participation_id': participationId,
      'name': name,
      'description': description,
      'images_paths': imagesPaths,
    };
  }

  Work copyWith({
    String? id,
    DateTime? createdAt,
    String? participationId,
    String? name,
    String? description,
    List<String>? imagesPaths,
  }) {
    return Work(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      participationId: participationId ?? this.participationId,
      name: name ?? this.name,
      description: description ?? this.description,
      imagesPaths: imagesPaths ?? this.imagesPaths,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        participationId,
        name,
        description,
        imagesPaths,
      ];
}
