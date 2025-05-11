import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/user_repository.dart';

part 'settings_page_event.dart';
part 'settings_page_state.dart';

class SettingsPageBloc extends Bloc<SettingsPageEvent, SettingsPageState> {
  final UserRepository _userRepository;
  final ProfileRepository _profileRepository;

  SettingsPageBloc({
    required UserRepository userRepository,
    required ProfileRepository profileRepository,
  })  : _userRepository = userRepository,
        _profileRepository = profileRepository,
        super(SettingsPageState(status: BlocStatus.initial)) {
    on<SettingsPageGetProfile>(_getProfile);
    on<SettingsPageSignOut>(_signOut);
  }

  FutureOr<void> _getProfile(
    SettingsPageGetProfile event,
    Emitter<SettingsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    final profileRes = await _profileRepository.getProfileById(id: event.userId);
    profileRes.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, profile: success)),
    );
  }

  FutureOr<void> _signOut(
    SettingsPageSignOut event,
    Emitter<SettingsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    final signOutRes = await _userRepository.signOut();
    signOutRes.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (unit) => emit(SettingsPageState(status: BlocStatus.success)),
    );
  }
}
