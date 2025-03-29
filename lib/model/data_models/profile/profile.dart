import 'package:swift_contest/model/data_models/profile/app_language.dart';
import 'package:swift_contest/model/data_models/profile/app_theme.dart';
import 'package:swift_contest/model/data_models/profile/contest_role.dart';

class Profile {
  final String id;
  final String firstName;
  final String lastName;
  final AppTheme prefAppTheme;
  final AppLanguage prefAppLanguage;
  final ContestRole prefContestRole;
  final bool isAlive;

  Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.prefAppTheme,
    required this.prefAppLanguage,
    required this.prefContestRole,
    required this.isAlive,
  });

  factory Profile.fromJson(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      prefAppTheme: AppTheme.values.byName(map['pref_app_theme']),
      prefAppLanguage: AppLanguage.values.byName(map['pref_app_language']),
      prefContestRole: ContestRole.values.byName(map['pref_contest_role']),
      isAlive: map['is_alive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'pref_app_theme': prefAppTheme.name,
      'pref_app_language': prefAppLanguage.name,
      'pref_contest_role': prefContestRole.name,
      'is_alive' : isAlive,
    };
  }

  Profile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    AppTheme? prefAppTheme,
    AppLanguage? prefAppLanguage,
    ContestRole? prefContestRole,
    bool? isAlive,
  }) {
    return Profile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      prefAppTheme: prefAppTheme ?? this.prefAppTheme,
      prefAppLanguage: prefAppLanguage ?? this.prefAppLanguage,
      prefContestRole: prefContestRole ?? this.prefContestRole,
      isAlive: isAlive ?? this.isAlive,
    );
  }
}
