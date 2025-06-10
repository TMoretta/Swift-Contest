// import 'dart:async';
//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:swift_contest/model/data_models/profile.dart';
// import 'package:swift_contest/model/enums/app_theme.dart';
// import 'package:swift_contest/model/repositories/crud_repositories/profile_repository.dart';
// import 'package:swift_contest/model/repositories/crud_repositories/user_repository.dart';
// import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
//
// part 'settings_page_event.dart';
//
// part 'settings_page_state.dart';
//
// class SettingsPageBloc extends Bloc<SettingsPageEvent, SettingsPageState> {
//   final UserRepository _userRepository;
//   final ProfileRepository _profileRepository;
//
//   SettingsPageBloc({
//     required UserRepository userRepository,
//     required ProfileRepository profileRepository,
//   })  : _userRepository = userRepository,
//         _profileRepository = profileRepository,
//         super(SettingsPageState(status: BlocStatus.initial)) {
//     on<SettingsPageInit>(_init);
//     on<SettingsPageSignOut>(_signOut);
//     on<SettingsPageEditPrefTheme>(_editPrefTheme);
//   }
//
//   Future<void> _init(
//     SettingsPageInit event,
//     Emitter<SettingsPageState> emit,
//   ) async {
//     emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));
//
//     late final Profile? profile;
//     final eitherProfile = await _profileRepository.getCurrentProfile();
//     eitherProfile.fold(
//         (failure) => emit(state.copyWith(status: BlocStatus.failure)),
//         (success) => {
//           if(success != null) {
//             emit(state.copyWith(status: BlocStatus.))
//           }
//         }
//     )
//   }
//
//   FutureOr<void> _signOut(
//     SettingsPageSignOut event,
//     Emitter<SettingsPageState> emit,
//   ) async {
//     emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));
//
//     final eitherSignOut = await _userRepository.signOut();
//     eitherSignOut.fold(
//       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
//       (success) => emit(state.copyWith(status: BlocStatus.success)),
//     );
//   }
//
//   FutureOr<void> _editPrefTheme(
//     SettingsPageEditPrefTheme event,
//     Emitter<SettingsPageState> emit,
//   ) async {
//     emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));
//
//     final eitherEditPrefTheme = await _profileRepository.updateProfile(
//         profile: event.profileToUpdate.copyWith(prefTheme: event.newPrefTheme));
//     eitherEditPrefTheme.fold(
//       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
//       (success) => emit(state.copyWith(status: BlocStatus.success)),
//     );
//   }
// }
