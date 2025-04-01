part of 'settings_page_bloc.dart';

@immutable
final class SettingsPageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final Profile? profile;

  const SettingsPageState({
    required this.status,
    this.message,
    this.profile,
  });

  SettingsPageState copyWith({
    required BlocStatus status,
    String? message,
    Profile? profile,
  }) {
    return SettingsPageState(
      status: status,
      message: message,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [status, message, profile];
}
