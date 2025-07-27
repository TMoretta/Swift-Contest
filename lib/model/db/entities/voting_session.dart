import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/db/types/voting_session_status.dart';

class VotingSession extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String name;
  final String? contestId;
  final bool areSimpleJurorsAllowed;
  final Duration workTimer;
  final Duration intermissionTimer;
  final Duration reviewTimer;
  final String? token;
  final bool isGeoRestricted;
  final String? geoResPlaceId;
  final int? geoResRadius;

  // Procedure attributes
  final VotingSessionStatus sessionStatus;
  final int? currentParticipantIndex;
  final DateTime? currentStepDeadline;

  const VotingSession({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.contestId,
    required this.areSimpleJurorsAllowed,
    required this.workTimer,
    required this.intermissionTimer,
    required this.reviewTimer,
    required this.token,
    required this.isGeoRestricted,
    required this.geoResPlaceId,
    required this.geoResRadius,
    required this.sessionStatus,
    this.currentParticipantIndex,
    this.currentStepDeadline,
  });

  factory VotingSession.fromJson(Map<String, dynamic> json) {
    return VotingSession(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      name: json['name'] as String,
      contestId: json['contest_id'] as String,
      areSimpleJurorsAllowed: json['are_simple_jurors_allowed'] as bool,
      workTimer: Duration(seconds: json['work_timer']),
      intermissionTimer: Duration(seconds: json['intermission_timer']),
      reviewTimer: Duration(seconds: json['review_timer']),
      token: json['token'] as String,
      isGeoRestricted: json['is_geo_restricted'] as bool,
      geoResPlaceId: json['geo_res_place_id'] as String?,
      geoResRadius: json['geo_res_radius'] as int?,
      sessionStatus: VotingSessionStatus.values.byName(json['session_status']),
      currentParticipantIndex: json['current_participant_index'] as int?,
      currentStepDeadline: (json['current_step_deadline'] != null)
          ? DateTime.parse(json['current_step_deadline']).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if(id!=null) 'id': id,
      if(createdAt!=null) 'created_at': createdAt!.toUtc().toIso8601String(),
      'name': name,
      if(contestId!=null) 'contest_id': contestId,
      'are_simple_jurors_allowed': areSimpleJurorsAllowed,
      'work_timer': workTimer.inSeconds,
      'intermission_timer': intermissionTimer.inSeconds,
      'review_timer': reviewTimer.inSeconds,
      if(token!=null) 'token': token,
      'is_geo_restricted': isGeoRestricted,
      if (geoResPlaceId != null) 'geo_res_place_id': geoResPlaceId,
      if (geoResRadius != null) 'geo_res_radius': geoResRadius,
      'session_status': sessionStatus.name,
      if(currentParticipantIndex!=null) 'current_participant_index': currentParticipantIndex,
      if(currentStepDeadline!=null) 'current_step_deadline': currentStepDeadline!.toUtc().toIso8601String(),
    };
  }

  VotingSession copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? contestId,
    bool? areSimpleJurorsAllowed,
    Duration? workTimer,
    Duration? intermissionTimer,
    Duration? reviewTimer,
    String? token,
    bool? isGeoRestricted,
    String? geoResPlaceId,
    int? geoResRadius,
    VotingSessionStatus? sessionStatus,
    int? currentParticipantIndex,
    DateTime? currentStepDeadline,
  }) {
    return VotingSession(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      contestId: contestId ?? this.contestId,
      areSimpleJurorsAllowed: areSimpleJurorsAllowed ?? this.areSimpleJurorsAllowed,
      workTimer: workTimer ?? this.workTimer,
      intermissionTimer: intermissionTimer ?? this.intermissionTimer,
      reviewTimer: reviewTimer ?? this.reviewTimer,
      token: token ?? this.token,
      isGeoRestricted: isGeoRestricted ?? this.isGeoRestricted,
      geoResPlaceId: geoResPlaceId ?? this.geoResPlaceId,
      geoResRadius: geoResRadius ?? this.geoResRadius,
      sessionStatus: sessionStatus ?? this.sessionStatus,
      currentParticipantIndex: currentParticipantIndex ?? this.currentParticipantIndex,
      currentStepDeadline: currentStepDeadline ?? this.currentStepDeadline,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        name,
        contestId,
        areSimpleJurorsAllowed,
        workTimer,
        intermissionTimer,
        reviewTimer,
        token,
        isGeoRestricted,
        geoResPlaceId,
        geoResRadius,
        sessionStatus,
        currentParticipantIndex,
        currentStepDeadline,
      ];
}
