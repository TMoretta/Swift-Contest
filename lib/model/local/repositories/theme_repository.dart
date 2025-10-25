import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swift_contest/model/local/types/app_theme.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class ThemeRepository {
  Future<Either<Failure, Unit>> saveTheme(AppTheme theme);

  Future<AppTheme> loadTheme();
}

class ThemeRepositoryImpl implements ThemeRepository {
  final SharedPreferences _preferences;
  final String _key;

  ThemeRepositoryImpl({
    required SharedPreferences sharedPreferencesInstance,
    required String key,
  })  : _preferences = sharedPreferencesInstance,
        _key = key;

  @override
  Future<Either<Failure, Unit>> saveTheme(AppTheme theme) async {
    try {
      await _preferences.setString(_key, theme.name);
      return Either.right(unit);
    } catch (e) {
      return Either.left(const Failure());
    }
  }

  @override
  Future<AppTheme> loadTheme() async {
    try {
      final value = _preferences.getString(_key);

      return AppTheme.values.byName(value ?? 'system');
    } catch (e) {
      return AppTheme.system;
    }
  }
}
