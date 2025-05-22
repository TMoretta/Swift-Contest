import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/enums/contest_status.dart';

class Contest extends Equatable {
  final String id;
  final DateTime createdAt;
  final String organizerId;
  final String name;
  final String description;
  final DateTime dateTime;
  final DateTime worksSubmissionFrom;
  final DateTime worksSubmissionTo;
  final String placeId;
  final ContestStatus contestStatus;
  final List<String> imagesUrls;
  final String token;
  final String votingFormId;
  final bool isDeleted;

  const Contest({
    required this.id,
    required this.createdAt,
    required this.organizerId,
    required this.name,
    required this.description,
    required this.dateTime,
    required this.worksSubmissionFrom,
    required this.worksSubmissionTo,
    required this.placeId,
    required this.contestStatus,
    required this.imagesUrls,
    required this.token,
    required this.votingFormId,
    required this.isDeleted,
  });

  factory Contest.fromJson(Map<String, dynamic> json) {
    return Contest(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      organizerId: json['organizer_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      dateTime: DateTime.parse(json['date_time']).toLocal(),
      worksSubmissionFrom: DateTime.parse(json['works_submission_from']).toLocal(),
      worksSubmissionTo: DateTime.parse(json['works_submission_to']).toLocal(),
      placeId: json['place_id'] as String,
      contestStatus: ContestStatus.values.byName(json['contest_status'] as String),
      imagesUrls: List<String>.from(json['images_urls']),
      token: json['token'] as String,
      votingFormId: json['voting_form_id'] as String,
      isDeleted: json['is_deleted'] as bool,
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
      'works_submission_from': worksSubmissionFrom.toUtc().toIso8601String(),
      'works_submission_to': worksSubmissionTo.toUtc().toIso8601String(),
      'place_id': placeId,
      'contest_status': contestStatus.name,
      'images_urls': imagesUrls,
      'token': token,
      'voting_form_id': votingFormId,
      'is_deleted': isDeleted,
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
      'p_works_submission_from': worksSubmissionFrom.toUtc().toIso8601String(),
      'p_works_submission_to': worksSubmissionTo.toUtc().toIso8601String(),
      'p_place_id': placeId,
      'p_contest_status': contestStatus.name,
      'p_images_urls': imagesUrls,
      'p_token': token,
      'p_voting_form_id': votingFormId,
      'p_is_deleted': isDeleted,
    };
  }

  Contest copyWith({
    String? id,
    DateTime? createdAt,
    String? organizerId,
    String? name,
    String? description,
    DateTime? dateTime,
    DateTime? worksSubmissionFrom,
    DateTime? worksSubmissionTo,
    String? placeId,
    ContestStatus? contestStatus,
    List<String>? imagesUrls,
    String? token,
    String? votingFormId,
    bool? isDeleted,
  }) {
    return Contest(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      organizerId: organizerId ?? this.organizerId,
      name: name ?? this.name,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      worksSubmissionFrom: worksSubmissionFrom ?? this.worksSubmissionFrom,
      worksSubmissionTo: worksSubmissionTo ?? this.worksSubmissionTo,
      placeId: placeId ?? this.placeId,
      contestStatus: contestStatus ?? this.contestStatus,
      imagesUrls: imagesUrls ?? this.imagesUrls,
      token: token ?? this.token,
      votingFormId: votingFormId ?? this.votingFormId,
      isDeleted: isDeleted ?? this.isDeleted,
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
        worksSubmissionFrom,
        worksSubmissionTo,
        placeId,
        contestStatus,
        imagesUrls,
        token,
        votingFormId,
        isDeleted,
      ];
}
