import 'package:equatable/equatable.dart';

class ContestRanking extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? contestId;
  final String name;
  final String filePath;
  final DateTime? publishedAt;

  const ContestRanking({
    required this.id,
    required this.createdAt,
    required this.contestId,
    required this.name,
    required this.filePath,
    required this.publishedAt,
  });

  factory ContestRanking.fromJson(Map<String, dynamic> json) {
    return ContestRanking(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      contestId: json['contest_id'],
      name: json['name'],
      filePath: json['file_path'],
      publishedAt: DateTime.parse(json['published_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (contestId != null) 'contest_id': contestId,
      'name': name,
      'file_path': filePath,
      if (publishedAt != null) 'published_at': publishedAt!.toIso8601String(),
    };
  }

  ContestRanking copyWith({
    String? id,
    DateTime? createdAt,
    String? contestId,
    String? name,
    String? filePath,
    DateTime? publishedAt,
  }) {
    return ContestRanking(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contestId: contestId ?? this.contestId,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        contestId,
        name,
        filePath,
        publishedAt,
      ];
}
