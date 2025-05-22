import 'package:equatable/equatable.dart';

class Work extends Equatable {
  final String id;
  final DateTime createdAt;
  final String participationId;
  final String name;
  final String description;
  final List<String> imagesUrls;

  const Work({
    required this.id,
    required this.createdAt,
    required this.participationId,
    required this.name,
    required this.description,
    required this.imagesUrls,
  });

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      participationId: json['participation_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imagesUrls: List<String>.from(json['images_urls']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'participation_id': participationId,
      'name': name,
      'description': description,
      'images_urls': imagesUrls,
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
      'p_participation_id': participationId,
      'p_name': name,
      'p_description': description,
      'p_images_urls': imagesUrls,
    };
  }

  Work copyWith({
    String? id,
    DateTime? createdAt,
    String? participationId,
    String? name,
    String? description,
    List<String>? imagesUrls,
  }) {
    return Work(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      participationId: participationId ?? this.participationId,
      name: name ?? this.name,
      description: description ?? this.description,
      imagesUrls: imagesUrls ?? this.imagesUrls,
    );
  }


  @override
  List<Object?> get props => [id, createdAt, participationId, name, description, imagesUrls,];
}
