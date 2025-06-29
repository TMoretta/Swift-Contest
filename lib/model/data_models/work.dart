import 'package:equatable/equatable.dart';

class Work extends Equatable {
  final String id;
  final DateTime createdAt;
  final String participationId;
  final String name;
  final String description;
  final List<String> imagesUrls;
  final String fileUrl;

  const Work({
    required this.id,
    required this.createdAt,
    required this.participationId,
    required this.name,
    required this.description,
    required this.imagesUrls,
    required this.fileUrl,
  });

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      participationId: json['participation_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imagesUrls: List<String>.from(json['images_urls']),
      fileUrl: json['file_url'] as String,
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
      'file_url': fileUrl,
    };
  }

  Work copyWith({
    String? id,
    DateTime? createdAt,
    String? participationId,
    String? name,
    String? description,
    List<String>? imagesUrls,
    String? fileUrl,
  }) {
    return Work(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      participationId: participationId ?? this.participationId,
      name: name ?? this.name,
      description: description ?? this.description,
      imagesUrls: imagesUrls ?? this.imagesUrls,
      fileUrl: fileUrl ?? this.fileUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        participationId,
        name,
        description,
        imagesUrls,
        fileUrl,
      ];
}

class WorkNullable extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? participationId;
  final String? name;
  final String? description;
  final List<String>? imagesUrls;
  final String? fileUrl;

  const WorkNullable({
    this.id,
    this.createdAt,
    this.participationId,
    this.name,
    this.description,
    this.imagesUrls,
    this.fileUrl,
  });

  @override
  List<Object?> get props => [
        id,
        createdAt,
        participationId,
        name,
        description,
        imagesUrls,
        fileUrl,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'participation_id': participationId,
      'name': name,
      'description': description,
      'images_urls': imagesUrls,
      'file_url': fileUrl,
    };
  }
}
