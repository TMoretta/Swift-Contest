import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/db/types/voting_session_status.dart';

class VotingSession extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String name;
  final String? contestId;
  final bool isGeoRestricted;
  final String? geoResPlaceId;
  final int? geoResRadius;
  final VotingSessionStatus sessionStatus;

  const VotingSession({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.contestId,
    required this.isGeoRestricted,
    required this.geoResPlaceId,
    required this.geoResRadius,
    required this.sessionStatus,
  });

  factory VotingSession.fromJson(Map<String, dynamic> json) {
    return VotingSession(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      name: json['name'] as String,
      contestId: json['contest_id'] as String,
      isGeoRestricted: json['is_geo_restricted'] as bool,
      geoResPlaceId: json['geo_res_place_id'] as String?,
      geoResRadius: json['geo_res_radius'] as int?,
      sessionStatus: VotingSessionStatus.values.byName(json['session_status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if(id!=null) 'id': id,
      if(createdAt!=null) 'created_at': createdAt!.toUtc().toIso8601String(),
      'name': name,
      if(contestId!=null) 'contest_id': contestId,
      'is_geo_restricted': isGeoRestricted,
      if (geoResPlaceId != null) 'geo_res_place_id': geoResPlaceId,
      if (geoResRadius != null) 'geo_res_radius': geoResRadius,
      'session_status': sessionStatus.name,
    };
  }

  VotingSession copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? contestId,
    bool? isGeoRestricted,
    String? geoResPlaceId,
    int? geoResRadius,
    VotingSessionStatus? sessionStatus,
  }) {
    return VotingSession(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      contestId: contestId ?? this.contestId,
      isGeoRestricted: isGeoRestricted ?? this.isGeoRestricted,
      geoResPlaceId: geoResPlaceId ?? this.geoResPlaceId,
      geoResRadius: geoResRadius ?? this.geoResRadius,
      sessionStatus: sessionStatus ?? this.sessionStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        name,
        contestId,
        isGeoRestricted,
        geoResPlaceId,
        geoResRadius,
        sessionStatus,
      ];
}
