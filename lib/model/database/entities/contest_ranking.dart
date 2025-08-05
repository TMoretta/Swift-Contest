import 'package:equatable/equatable.dart';

class ContestRanking extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? contestId;
  final String filePath;

  const ContestRanking({
    required this.id,
    required this.createdAt,
    required this.contestId,
    required this.filePath,
  });

  factory ContestRanking.fromJson(Map<String, dynamic> json) {
    return ContestRanking(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      contestId: json['contest_id'],
      filePath: json['file_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (contestId != null) 'contest_id': contestId,
      'file_path': filePath,
    };
  }

  ContestRanking copyWith({
    String? id,
    DateTime? createdAt,
    String? contestId,
    String? filePath,
  }) {
    return ContestRanking(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contestId: contestId ?? this.contestId,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        contestId,
        filePath,
      ];
}
