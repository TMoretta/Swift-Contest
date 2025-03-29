abstract class Constants {
  static const String supabaseUrl = String.fromEnvironment(
    'supabaseUrl',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'supabaseAnonKey',
    defaultValue: '',
  );

  static const String googlePlacesApiKey = String.fromEnvironment(
    'googlePlacesApiKey',
    defaultValue: '',
  );
}
