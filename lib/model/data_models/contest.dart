import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/enums/contest_status.dart';

class Contest extends Equatable {
  final String id;
  final DateTime createdAt;
  final String organizerId;
  final String name;
  final String description;
  final DateTime dateTime;
  final DateTime worksSubmissionStart;
  final DateTime worksSubmissionEnd;
  final List<String> imagesUrls;
  final String placeId;
  final ContestStatus contestStatus;
  final String token;
  final String votingFormId;
  final DateTime? deletedAt;

  const Contest({
    required this.id,
    required this.createdAt,
    required this.organizerId,
    required this.name,
    required this.description,
    required this.dateTime,
    required this.worksSubmissionStart,
    required this.worksSubmissionEnd,
    required this.imagesUrls,
    required this.placeId,
    required this.contestStatus,
    required this.token,
    required this.votingFormId,
     this.deletedAt,
  });

  factory Contest.fromJson(Map<String, dynamic> json) {
    return Contest(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      organizerId: json['organizer_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      dateTime: DateTime.parse(json['date_time']).toLocal(),
      worksSubmissionStart: DateTime.parse(json['works_submission_start']).toLocal(),
      worksSubmissionEnd: DateTime.parse(json['works_submission_end']).toLocal(),
      placeId: json['place_id'] as String,
      contestStatus: ContestStatus.values.byName(json['contest_status'] as String),
      imagesUrls: List<String>.from(json['images_urls']),
      token: json['token'] as String,
      votingFormId: json['voting_form_id'] as String,
      deletedAt: (json['deleted_at'] != null) ? DateTime.parse(json['deleted_at']).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'organizer_id': organizerId,
      'name': name,
      'description': description,
      'date_time': dateTime.toUtc().toIso8601String(),
      'works_submission_start': worksSubmissionStart.toUtc().toIso8601String(),
      'works_submission_end': worksSubmissionEnd.toUtc().toIso8601String(),
      'place_id': placeId,
      'contest_status': contestStatus.name,
      'images_urls': imagesUrls,
      'token': token,
      'voting_form_id': votingFormId,
      'deleted_at': deletedAt,
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
      'p_organizer_id': organizerId,
      'p_name': name,
      'p_description': description,
      'p_date_time': dateTime.toUtc().toIso8601String(),
      'p_works_submission_from': worksSubmissionStart.toUtc().toIso8601String(),
      'p_works_submission_to': worksSubmissionEnd.toUtc().toIso8601String(),
      'p_place_id': placeId,
      'p_contest_status': contestStatus.name,
      'p_images_urls': imagesUrls,
      'p_token': token,
      'p_voting_form_id': votingFormId,
      'p_deleted_at': deletedAt,
    };
  }

  Contest copyWith({
    String? id,
    DateTime? createdAt,
    String? organizerId,
    String? name,
    String? description,
    DateTime? dateTime,
    DateTime? worksSubmissionStart,
    DateTime? worksSubmissionEnd,
    String? placeId,
    ContestStatus? contestStatus,
    List<String>? imagesUrls,
    String? token,
    String? votingFormId,
    DateTime? deletedAt,
  }) {
    return Contest(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      organizerId: organizerId ?? this.organizerId,
      name: name ?? this.name,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      worksSubmissionStart: worksSubmissionStart ?? this.worksSubmissionStart,
      worksSubmissionEnd: worksSubmissionEnd ?? this.worksSubmissionEnd,
      placeId: placeId ?? this.placeId,
      contestStatus: contestStatus ?? this.contestStatus,
      imagesUrls: imagesUrls ?? this.imagesUrls,
      token: token ?? this.token,
      votingFormId: votingFormId ?? this.votingFormId,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        organizerId,
        name,
        description,
        dateTime,
        worksSubmissionStart,
        worksSubmissionEnd,
        placeId,
        contestStatus,
        imagesUrls,
        token,
        votingFormId,
        deletedAt,
      ];
}

class ContestNullable extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? organizerId;
  final String? name;
  final String? description;
  final DateTime? dateTime;
  final DateTime? worksSubmissionStart;
  final DateTime? worksSubmissionEnd;
  final List<String>? imagesUrls;
  final String? placeId;
  final ContestStatus? contestStatus;
  final String? token;
  final String? votingFormId;
  final DateTime? deletedAt;

  const ContestNullable({
    this.id,
    this.createdAt,
    this.organizerId,
    this.name,
    this.description,
    this.dateTime,
    this.worksSubmissionStart,
    this.worksSubmissionEnd,
    this.imagesUrls,
    this.placeId,
    this.contestStatus,
    this.token,
    this.votingFormId,
    this.deletedAt,
  });

  Map<String,dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'organizer_id': organizerId,
      'name': name,
      'description': description,
      'date_time': dateTime?.toUtc().toIso8601String(),
      'works_submission_start': worksSubmissionStart?.toUtc().toIso8601String(),
      'works_submission_end': worksSubmissionEnd?.toUtc().toIso8601String(),
      'place_id': placeId,
      'contest_status': contestStatus?.name,
      'images_urls': imagesUrls,
      'token': token,
      'voting_form_id': votingFormId,
      'deleted_at': deletedAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    organizerId,
    name,
    description,
    dateTime,
    worksSubmissionStart,
    worksSubmissionEnd,
    placeId,
    contestStatus,
    imagesUrls,
    token,
    votingFormId,
    deletedAt,
  ];
}
