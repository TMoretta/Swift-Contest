part of 'settings_page_bloc.dart';

sealed class SettingsPageEvent extends Equatable {
  const SettingsPageEvent();
}

final class SettingsPageGetProfile extends SettingsPageEvent {
  final String userId;

  const SettingsPageGetProfile({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final class SettingsPageSignOut extends SettingsPageEvent {
  @override
  List<Object?> get props => [];
}
