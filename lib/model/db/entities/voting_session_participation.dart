import 'package:equatable/equatable.dart';

class VotingSessionParticipation extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionId;
  final String? participationId;
  final int orderIndex;

  // Snapshot data
  final String participantFullName;
  final String workName;
  final String workDescription;
  final List<String> workImagesUrls;

  const VotingSessionParticipation({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.participationId,
    required this.orderIndex,
    required this.participantFullName,
    required this.workName,
    required this.workDescription,
    required this.workImagesUrls,
  });

  factory VotingSessionParticipation.fromJson(Map<String, dynamic> json) {
    return VotingSessionParticipation(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      participationId: json['participation_id'] as String,
      orderIndex: json['order_index'] as int,
      participantFullName: json['participant_full_name'] as String,
      workName: json['work_name'] as String,
      workDescription: json['work_description'] as String,
      workImagesUrls: List<String>.from(json['work_images_urls']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (votingSessionId != null) 'voting_session_id': votingSessionId,
      if (participationId != null) 'participation_id': participationId,
      'order_index': orderIndex,
      'participant_full_name': participantFullName,
      'work_name': workName,
      'work_description': workDescription,
      'work_images_urls': workImagesUrls,
    };
  }

  VotingSessionParticipation copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? participationId,
    int? orderIndex,
    bool? isExcluded,
    String? participantFullName,
    String? workName,
    String? workDescription,
    List<String>? workImagesUrls,
  }) {
    return VotingSessionParticipation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      participationId: participationId ?? this.participationId,
      orderIndex: orderIndex ?? this.orderIndex,
      participantFullName: participantFullName ?? this.participantFullName,
      workName: workName ?? this.workName,
      workDescription: workDescription ?? this.workDescription,
      workImagesUrls: workImagesUrls ?? this.workImagesUrls,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionId,
        participationId,
        orderIndex,
        participantFullName,
        workName,
        workDescription,
        workImagesUrls,
      ];
}
