// part of 'settings_page_bloc.dart';
//
// sealed class SettingsPageEvent extends Equatable {
//   const SettingsPageEvent();
// }
//
// final class SettingsPageInit extends SettingsPageEvent {
//   final String userId;
//   const SettingsPageInit({required this.userId});
//
//   @override
//   List<Object?> get props => [userId];
// }
//
// final class SettingsPageSignOut extends SettingsPageEvent {
//   @override
//   List<Object?> get props => [];
// }
//
// final class SettingsPageEditPrefTheme extends SettingsPageEvent {
//   final Profile profileToUpdate;
//   final AppTheme newPrefTheme;
//
//   const SettingsPageEditPrefTheme({required this.profileToUpdate, required this.newPrefTheme});
//
//   @override
//   List<Object?> get props => [profileToUpdate, newPrefTheme];
// }
