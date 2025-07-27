import 'package:equatable/equatable.dart';

class Work extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? participationId;
  final String participantFullName;
  final String name;
  final String description;
  final List<String> imagesUrls;
  final String fileUrl;

  const Work({
    required this.id,
    required this.createdAt,
    required this.participationId,
    required this.participantFullName,
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
      participantFullName: json['participant_full_name'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imagesUrls: List<String>.from(json['images_urls']),
      fileUrl: json['file_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if(id!=null) 'id': id,
      if(createdAt!=null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if(participationId!=null) 'participation_id': participationId,
      'participant_full_name': participantFullName,
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
    String? participantFullName,
    String? name,
    String? description,
    List<String>? imagesUrls,
    String? fileUrl,
  }) {
    return Work(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      participationId: participationId ?? this.participationId,
      participantFullName: participantFullName ?? this.participantFullName,
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
        participantFullName,
        name,
        description,
        imagesUrls,
        fileUrl,
      ];
}
