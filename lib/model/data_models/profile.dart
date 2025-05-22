import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/enums/app_theme.dart';
import 'package:swift_contest/model/enums/contest_role.dart';

class Profile extends Equatable {
  final String id;
  final DateTime createdAt;
  final String fullName;
  final AppTheme prefTheme;
  final ContestRole prefContestRole;
  final bool isDeleted;

  const Profile({
    required this.id,
    required this.createdAt,
    required this.fullName,
    required this.prefTheme,
    required this.prefContestRole,
    required this.isDeleted,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      fullName: json['full_name'] as String,
      prefTheme: AppTheme.values.byName(json['pref_theme']),
      prefContestRole: ContestRole.values.byName(json['pref_contest_role']),
      isDeleted: json['is_deleted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'full_name': fullName,
      'pref_theme': prefTheme.name,
      'pref_contest_role': prefContestRole.name,
      'is_deleted': isDeleted,
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
      'p_full_name': fullName,
      'p_pref_theme': prefTheme.name,
      'p_pref_contest_role': prefContestRole.name,
      'p_is_deleted': isDeleted,
    };
  }

  Profile copyWith({
    String? id,
    DateTime? createdAt,
    String? fullName,
    AppTheme? prefTheme,
    ContestRole? prefContestRole,
    bool? isDeleted,
  }) {
    return Profile(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      fullName: fullName ?? this.fullName,
      prefTheme: prefTheme ?? this.prefTheme,
      prefContestRole: prefContestRole ?? this.prefContestRole,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }


  @override
  List<Object?> get props =>
      [id, createdAt, fullName, prefTheme, prefContestRole, isDeleted];
}

typedef Organizer = Profile;
typedef Participant = Profile;
typedef Juror = Profile;
