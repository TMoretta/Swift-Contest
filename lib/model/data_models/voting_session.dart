import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/enums/voting_session_status.dart';

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
  final String token;
  final bool isGeoRestricted;
  final String? geoRestrictionPlaceId;
  final int? geoRestrictionRadius;

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
    required this.votingFormId,
    required this.workTimer,
    required this.intermissionTimer,
    required this.reviewTimer,
    required this.token,
    required this.isGeoRestricted,
    required this.geoRestrictionPlaceId,
    required this.geoRestrictionRadius,
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
      votingFormId: json['voting_form_id'] as String,
      workTimer: Duration(seconds: json['work_timer']),
      intermissionTimer: Duration(seconds: json['intermission_timer']),
      reviewTimer: Duration(seconds: json['review_timer']),
      token: json['token'] as String,
      isGeoRestricted: json['is_geo_restricted'] as bool,
      geoRestrictionPlaceId: json['geo_restriction_place_id'] as String?,
      geoRestrictionRadius: json['geo_restriction_radius'] as int?,
      sessionStatus: VotingSessionStatus.values.byName(json['session_status']),
      currentParticipantIndex: json['current_participant_index'] as int?,
      currentStepDeadline: (json['current_step_deadline'] != null)
          ? DateTime.parse(json['current_step_deadline']).toLocal()
          : null,
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
      'token': token,
      'is_geo_restricted': isGeoRestricted,
      'geo_restriction_place_id': geoRestrictionPlaceId,
      'geo_restriction_radius': geoRestrictionRadius,
      'session_status': sessionStatus.name,
      'current_participant_index': currentParticipantIndex,
      'current_step_deadline': currentStepDeadline?.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
      'p_name': name,
      'p_contest_id': contestId,
      'p_are_simple_jurors_allowed': areSimpleJurorsAllowed,
      'p_voting_form_id': votingFormId,
      'p_work_timer': workTimer.inSeconds,
      'p_intermission_timer': intermissionTimer.inSeconds,
      'p_review_timer': reviewTimer.inSeconds,
      'p_token': token,
      'p_is_geo_restricted': isGeoRestricted,
      'p_geo_restriction_place_id': geoRestrictionPlaceId,
      'p_geo_restriction_radius': geoRestrictionRadius,
      'p_session_status': sessionStatus.name,
      'p_current_participant_index': currentParticipantIndex,
      'p_current_step_deadline': currentStepDeadline?.toUtc().toIso8601String(),
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
    String? token,
    bool? isGeoRestricted,
    String? geoRestrictionPlaceId,
    int? geoRestrictionRadius,
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
      votingFormId: votingFormId ?? this.votingFormId,
      workTimer: workTimer ?? this.workTimer,
      intermissionTimer: intermissionTimer ?? this.intermissionTimer,
      reviewTimer: reviewTimer ?? this.reviewTimer,
      token: token ?? this.token,
      isGeoRestricted: isGeoRestricted ?? this.isGeoRestricted,
      geoRestrictionPlaceId: geoRestrictionPlaceId ?? this.geoRestrictionPlaceId,
      geoRestrictionRadius: geoRestrictionRadius ?? this.geoRestrictionRadius,
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
        votingFormId,
        workTimer,
        intermissionTimer,
        reviewTimer,
        token,
        isGeoRestricted,
        geoRestrictionPlaceId,
        geoRestrictionRadius,
        sessionStatus,
        currentParticipantIndex,
        currentStepDeadline,
      ];
}
