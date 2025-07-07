part of 'theme_bloc.dart';

@immutable
final class ThemeState extends Equatable {
  final BlocStatus status;
  final ThemeEvent? sourceEvent;
  final String? message;
  final AppTheme? theme;

  const ThemeState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.theme,
  });

  ThemeState copyWith({
    required BlocStatus status,
    ThemeEvent? sourceEvent,
    String? message,
    AppTheme? theme,
  }) {
    return ThemeState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      theme: theme ?? this.theme,
    );
  }

  factory ThemeState.fromJson(Map<String, dynamic> json) {
    return ThemeState(
      status: BlocStatus.values.byName(json['status']),
      theme: AppTheme.values.byName(json['theme']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'theme': theme?.name,
    };
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
      ];
}
