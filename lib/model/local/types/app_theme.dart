enum AppTheme {
  system,
  light,
  dark,
}

extension AppThemeX on AppTheme {
  bool get isSystem => this == AppTheme.system;
  bool get isLight => this == AppTheme.light;
  bool get isDark => this == AppTheme.dark;
}