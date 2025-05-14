import 'package:equatable/equatable.dart';

class VotingSession extends Equatable {
  final String id;
  final DateTime createdAt;
  final String name;
  final String contestId;
  final bool areSimpleJurorsAllowed;
  final String votingFormId;
  final Duration workTimer;
  final Duration intermissionTimer;
  final Duration reviewTimer;
  final bool isEnded;
  final String token;
  final bool isGeoRestricted;
  final String? geoRestrictionPlaceId;
  final int? geoRestrictionRadius;

  const VotingSession({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.contestId,
    required this.areSimpleJurorsAllowed,
    required this.votingFormId,
    required this.workTimer,
    required this.intermissionTimer,
    required this.reviewTimer,
    required this.isEnded,
    required this.token,
    required this.isGeoRestricted,
    required this.geoRestrictionPlaceId,
    required this.geoRestrictionRadius,
  });

  factory VotingSession.fromJson(Map<String, dynamic> json) {
    return VotingSession(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      name: json['name'] as String,
      contestId: json['contest_id'] as String,
      areSimpleJurorsAllowed: json['are_simple_jurors_allowed'] as bool,
      votingFormId: json['voting_form_id'] as String,
      workTimer: Duration(seconds: json['work_timer']),
      intermissionTimer: Duration(seconds: json['intermission_timer']),
      reviewTimer: Duration(seconds: json['review_timer']),
      isEnded: json['is_ended'] as bool,
      token: json['token'] as String,
      isGeoRestricted: json['is_geo_restricted'] as bool,
      geoRestrictionPlaceId: json['geo_restriction_place_id'] as String?,
      geoRestrictionRadius: json['geo_restriction_radius'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'name': name,
      'contest_id': contestId,
      'are_simple_jurors_allowed': areSimpleJurorsAllowed,
      'voting_form_id': votingFormId,
      'work_timer': workTimer.inSeconds,
      'intermission_timer': intermissionTimer.inSeconds,
      'review_timer': reviewTimer.inSeconds,
      'is_ended': isEnded,
      'token': token,
      'is_geo_restricted': isGeoRestricted,
      'geo_restriction_place_id': geoRestrictionPlaceId,
      'geo_restriction_radius': geoRestrictionRadius,
    };
  }

  VotingSession copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? contestId,
    bool? areSimpleJurorsAllowed,
    String? votingFormId,
    Duration? workTimer,
    Duration? intermissionTimer,
    Duration? reviewTimer,
    bool? isEnded,
    String? token,
    bool? isGeoRestricted,
    String? geoRestrictionPlaceId,
    int? geoRestrictionRadius,
  }) {
    return VotingSession(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      contestId: contestId ?? this.contestId,
      areSimpleJurorsAllowed: areSimpleJurorsAllowed ?? this.areSimpleJurorsAllowed,
      votingFormId: votingFormId ?? this.votingFormId,
      workTimer: workTimer ?? this.workTimer,
      intermissionTimer: intermissionTimer ?? this.intermissionTimer,
      reviewTimer: reviewTimer ?? this.reviewTimer,
      isEnded: isEnded ?? this.isEnded,
      token: token ?? this.token,
      isGeoRestricted: isGeoRestricted ?? this.isGeoRestricted,
      geoRestrictionPlaceId: geoRestrictionPlaceId ?? this.geoRestrictionPlaceId,
      geoRestrictionRadius: geoRestrictionRadius ?? this.geoRestrictionRadius,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        name,
        contestId,
        areSimpleJurorsAllowed,
        votingFormId,
        workTimer,
        intermissionTimer,
        reviewTimer,
        isEnded,
        token,
        isGeoRestricted,
        geoRestrictionPlaceId,
        geoRestrictionRadius,
      ];
}
