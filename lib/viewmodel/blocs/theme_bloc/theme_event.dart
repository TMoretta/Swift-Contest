part of 'theme_bloc.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();
}

final class LoadTheme extends ThemeEvent {
  @override
  List<Object?> get props => [];
}

final class SaveTheme extends ThemeEvent {
  final AppTheme theme;

  const SaveTheme({required this.theme});

  @override
  List<Object?> get props => [theme];
}
