import 'package:equatable/equatable.dart';

class Contest extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? organizerId;
  // final String organizerFullName;
  final String name;
  final String description;
  final DateTime dateTime;
  final DateTime worksSubmissionStart;
  final DateTime worksSubmissionEnd;
  final String? placeId;
  final List<String> imagesUrls;

  const Contest({
    required this.id,
    required this.createdAt,
    required this.organizerId,
    // required this.organizerFullName,
    required this.name,
    required this.description,
    required this.dateTime,
    required this.worksSubmissionStart,
    required this.worksSubmissionEnd,
    required this.imagesUrls,
    required this.placeId,
  });

  factory Contest.fromJson(Map<String, dynamic> json) {
    return Contest(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      organizerId: json['organizer_id'] as String,
      // organizerFullName: json['organizer_full_name'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      dateTime: DateTime.parse(json['date_time']).toLocal(),
      worksSubmissionStart: DateTime.parse(json['works_submission_start']).toLocal(),
      worksSubmissionEnd: DateTime.parse(json['works_submission_end']).toLocal(),
      placeId: json['place_id'] as String,
      imagesUrls: List<String>.from(json['images_urls']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if(id !=null) 'id' : id,
      if(createdAt !=null) 'created_at' : createdAt!.toUtc().toIso8601String(),
      if(organizerId!=null) 'organizer_id': organizerId,
      // 'organizer_full_name': organizerFullName,
      'name': name,
      'description': description,
      'date_time': dateTime.toUtc().toIso8601String(),
      'works_submission_start': worksSubmissionStart.toUtc().toIso8601String(),
      'works_submission_end': worksSubmissionEnd.toUtc().toIso8601String(),
      if(placeId!=null) 'place_id': placeId,
      'images_urls': imagesUrls,
    };
  }

  Contest copyWith({
    String? id,
    DateTime? createdAt,
    String? organizerId,
    // String? organizerFullName,
    String? name,
    String? description,
    DateTime? dateTime,
    DateTime? worksSubmissionStart,
    DateTime? worksSubmissionEnd,
    String? placeId,
    List<String>? imagesUrls,
  }) {
    return Contest(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      organizerId: organizerId ?? this.organizerId,
      // organizerFullName: organizerFullName ?? this.organizerFullName,
      name: name ?? this.name,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      worksSubmissionStart: worksSubmissionStart ?? this.worksSubmissionStart,
      worksSubmissionEnd: worksSubmissionEnd ?? this.worksSubmissionEnd,
      placeId: placeId ?? this.placeId,
      imagesUrls: imagesUrls ?? this.imagesUrls,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        organizerId,
        // organizerFullName,
        name,
        description,
        dateTime,
        worksSubmissionStart,
        worksSubmissionEnd,
        placeId,
        imagesUrls,
      ];
}
