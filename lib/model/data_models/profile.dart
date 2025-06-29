import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/enums/app_theme.dart';
import 'package:swift_contest/model/enums/contest_role.dart';

class Profile extends Equatable {
  final String id;
  final DateTime createdAt;
  final String userId;
  final String fullName;
  final AppTheme prefTheme;
  final ContestRole prefRole;
  final DateTime? deletedAt;

  const Profile({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.fullName,
    required this.prefTheme,
    required this.prefRole,
     this.deletedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      prefTheme: AppTheme.values.byName(json['pref_theme']),
      prefRole: ContestRole.values.byName(json['pref_role']),
      deletedAt: (json['deleted_at'] != null) ? DateTime.parse(json['deleted_at']).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'user_id': userId,
      'full_name': fullName,
      'pref_theme': prefTheme.name,
      'pref_role': prefRole.name,
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    DateTime? createdAt,
    String? userId,
    String? fullName,
    AppTheme? prefTheme,
    ContestRole? prefRole,
    DateTime? deletedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      prefTheme: prefTheme ?? this.prefTheme,
      prefRole: prefRole ?? this.prefRole,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        userId,
        fullName,
        prefTheme,
        prefRole,
        deletedAt,
      ];
}

class ProfileNullable extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? userId;
  final String? fullName;
  final AppTheme? prefTheme;
  final ContestRole? prefRole;
  final DateTime? deletedAt;

  const ProfileNullable({
    this.id,
    this.createdAt,
    this.userId,
    this.fullName,
    this.prefTheme,
    this.prefRole,
    this.deletedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'user_id': userId,
      'full_name': fullName,
      'pref_theme': prefTheme?.name,
      'pref_role': prefRole?.name,
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        userId,
        fullName,
        prefTheme,
        prefRole,
        deletedAt,
      ];
}


typedef Organizer = Profile;
typedef Participant = Profile;
typedef Juror = Profile;


