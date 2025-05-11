import 'package:equatable/equatable.dart';

class VotingSession extends Equatable {
  final String id;
  final DateTime createdAt;
  final String name;
  final String contestId;
  final bool isSimpleJurorVotingAllowed;
  final String votingFormId;
  final Duration workTimer;
  final Duration intermissionTimer;
  final Duration reviewTimer;
  final bool isEnded;

  const VotingSession({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.contestId,
    required this.isSimpleJurorVotingAllowed,
    required this.votingFormId,
    required this.workTimer,
    required this.intermissionTimer,
    required this.reviewTimer,
    required this.isEnded,
  });

  factory VotingSession.fromJson(Map<String, dynamic> json) {
    return VotingSession(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      name: json['name'] as String,
      contestId: json['contest_id'] as String,
      isSimpleJurorVotingAllowed: json['is_simple_juror_voting_allowed'] as bool,
      votingFormId: json['voting_form_id'] as String,
      workTimer: Duration(seconds: json['work_timer']),
      intermissionTimer: Duration(seconds: json['intermission_timer']),
      reviewTimer: Duration(seconds: json['review_timer']),
      isEnded: json['is_ended'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'name': name,
      'contest_id': contestId,
      'is_simple_juror_voting_allowed': isSimpleJurorVotingAllowed,
      'voting_form_id': votingFormId,
      'work_timer': workTimer.inSeconds,
      'intermission_timer': intermissionTimer.inSeconds,
      'review_timer': reviewTimer.inSeconds,
      'is_ended': isEnded,
    };
  }

  VotingSession copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? contestId,
    bool? isSimpleJurorVotingAllowed,
    String? votingFormId,
    Duration? workTimer,
    Duration? intermissionTimer,
    Duration? reviewTimer,
    bool? isEnded,
  }) {
    return VotingSession(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      contestId: contestId ?? this.contestId,
      isSimpleJurorVotingAllowed: isSimpleJurorVotingAllowed ?? this.isSimpleJurorVotingAllowed,
      votingFormId: votingFormId ?? this.votingFormId,
      workTimer: workTimer ?? this.workTimer,
      intermissionTimer: intermissionTimer ?? this.intermissionTimer,
      reviewTimer: reviewTimer ?? this.reviewTimer,
      isEnded: isEnded ?? this.isEnded,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        name,
        contestId,
        isSimpleJurorVotingAllowed,
        votingFormId,
        workTimer,
        intermissionTimer,
        reviewTimer,
        isEnded,
      ];
}
