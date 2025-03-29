import 'package:swift_contest/model/data_models/contest/contest_status.dart';
import 'package:swift_contest/model/data_models/contest/place.dart';

class Contest {
  final String id;
  final String name;
  final String description;
  final String organizerId;
  final Place place;
  final bool worksPreviewJurors;
  final DateTime dateTime;
  final DateTime worksDateTimeFrom;
  final DateTime worksDateTimeTo;
  final ContestStatus status;
  final List<String> imagesUrls;
  final String token;
  final bool isAlive;
  final String votingFormId;

  Contest({
    required this.id,
    required this.name,
    required this.description,
    required this.organizerId,
    required this.place,
    required this.worksPreviewJurors,
    required this.dateTime,
    required this.worksDateTimeFrom,
    required this.worksDateTimeTo,
    required this.status,
    required this.imagesUrls,
    required this.token,
    required this.isAlive,
    required this.votingFormId,
  });

  factory Contest.fromJson(Map<String, dynamic> map) {
    return Contest(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      organizerId: map['organizer_id'] as String,
      place: Place.fromJson(map['place']),
      worksPreviewJurors: map['works_preview_jurors'] as bool,
      dateTime: DateTime.parse(map['date_time']).toLocal(),
      worksDateTimeFrom: DateTime.parse(map['works_date_time_from']).toLocal(),
      worksDateTimeTo: DateTime.parse(map['works_date_time_to']).toLocal(),
      status: ContestStatus.values.byName(map['status']),
      imagesUrls: List<String>.from(map['images_urls']),
      token: map['token'] as String,
      isAlive: map['is_alive'] as bool,
      votingFormId: map['voting_form_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'organizer_id': organizerId,
      'place': place.toJson(),
      'works_preview_jurors': worksPreviewJurors,
      'date_time': dateTime.toUtc().toIso8601String(),
      'works_date_time_from': worksDateTimeFrom.toUtc().toIso8601String(),
      'works_date_time_to': worksDateTimeTo.toUtc().toIso8601String(),
      'status': status.name,
      'images_urls': imagesUrls,
      'token': token,
      'is_alive': isAlive,
      'voting_form_id': votingFormId,
    };
  }

  Contest copyWith({
    String? id,
    String? name,
    String? description,
    String? organizerId,
    Place? place,
    bool? worksPreviewJurors,
    DateTime? dateTime,
    DateTime? worksDateTimeFrom,
    DateTime? worksDateTimeTo,
    ContestStatus? status,
    List<String>? imagesUrls,
    String? token,
    bool? isAlive,
    String? votingFormId,
  }) {
    return Contest(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      organizerId: organizerId ?? this.organizerId,
      place: place ?? this.place,
      worksPreviewJurors: worksPreviewJurors ?? this.worksPreviewJurors,
      dateTime: dateTime ?? this.dateTime,
      worksDateTimeFrom: worksDateTimeFrom ?? this.worksDateTimeFrom,
      worksDateTimeTo: worksDateTimeTo ?? this.worksDateTimeTo,
      status: status ?? this.status,
      imagesUrls: imagesUrls ?? this.imagesUrls,
      token: token ?? this.token,
      isAlive: isAlive ?? this.isAlive,
      votingFormId: votingFormId ?? this.votingFormId,
    );
  }
}
