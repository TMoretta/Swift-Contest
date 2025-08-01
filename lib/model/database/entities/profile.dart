import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/types/contest_role.dart';

class Profile extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String fullName;
  final ContestRole prefRole;

  const Profile({
    required this.id,
    required this.createdAt,
    required this.fullName,
    required this.prefRole,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      fullName: json['full_name'] as String,
      prefRole: ContestRole.values.byName(json['pref_role']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      if (id != null)
        'id': id,
      if (createdAt != null)
        'created_at': createdAt!.toUtc().toIso8601String(),
      'full_name': fullName,
      'pref_role': prefRole.name,
    };
  }

  Profile copyWith({
    String? id,
    DateTime? createdAt,
    String? fullName,
    ContestRole? prefRole,
    DateTime? deletedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      fullName: fullName ?? this.fullName,
      prefRole: prefRole ?? this.prefRole,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        fullName,
        prefRole,
      ];
}

typedef Organizer = Profile;
typedef Participant = Profile;
typedef Juror = Profile;
