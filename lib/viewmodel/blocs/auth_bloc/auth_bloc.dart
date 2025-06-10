import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/model/enums/app_theme.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/model/repositories/crud_repositories/profile_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/user_repository.dart';
import 'package:swift_contest/viewmodel/enums/auth_status.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository _userRepository;
  final ProfileRepository _profileRepository;

  AuthBloc({
    required UserRepository userRepository,
    required ProfileRepository profileRepository,
  })  : _userRepository = userRepository,
        _profileRepository = profileRepository,
        super(AuthState(blocStatus: BlocStatus.initial, authStatus: AuthStatus.initial)) {
    on<AuthInit>(_init);
    on<AuthInitWithDelay>(_initWithDelay);
    on<AuthFetchUser>(_fetchUser);
    on<AuthFetchProfile>(_fetchProfile);
    on<AuthFetchUserAndProfile>(_fetchUserAndProfile);
    on<AuthSignOut>(_signOut);
    on<AuthEditPrefTheme>(_editPrefTheme);
    on<AuthEditPrefRole>(_editPrefRole);
    on<AuthEditFullName>(_editFullName);
  }

  //* Init the state
  FutureOr<void> _init(
    AuthInit event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(
        blocStatus: BlocStatus.loading, sourceEvent: event, authStatus: AuthStatus.initial));

    late final User? user;
    final eitherUser = _userRepository.getCurrentUser();
    eitherUser.fold(
      (failure) => emit(state.copyWith(
          blocStatus: BlocStatus.failure,
          authStatus: AuthStatus.initial,
          message: failure.message)),
      (success) => user = success,
    );
    if (eitherUser.isLeft()) {
      return;
    }
    if (user == null) {
      emit(state.copyWith(blocStatus: BlocStatus.success, authStatus: AuthStatus.unauthenticated));
      return;
    }

    late final Profile? profile;
    final eitherProfile = await _profileRepository.getProfileById(id: user!.id);
    eitherProfile.fold(
      (failure) => emit(state.copyWith(
          blocStatus: BlocStatus.failure,
          authStatus: AuthStatus.authenticated,
          user: user,
          message: failure.message)),
      (success) => profile = success,
    );
    if (eitherProfile.isLeft()) {
      return;
    }
    if (profile == null) {
      emit(state.copyWith(
          blocStatus: BlocStatus.failure,
          authStatus: AuthStatus.authenticated,
          message: 'Profile not found'));
      return;
    }

    emit(state.copyWith(
      blocStatus: BlocStatus.success,
      authStatus: AuthStatus.authenticated,
      user: user,
      profile: profile,
    ));
  }

  //* Init the state with a delay (for the splash page)
  Future<void> _initWithDelay(
    AuthInitWithDelay event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(
        blocStatus: BlocStatus.loading, sourceEvent: event, authStatus: AuthStatus.initial));
    if (event.delay != 0) {
      await Future.delayed(Duration(seconds: event.delay));
    }
    add(AuthInit());
  }

  FutureOr<void> _fetchUser(
    AuthFetchUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    late final User? user;
    final eitherUser = _userRepository.getCurrentUser();
    eitherUser.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => user = success,
    );

    if (user == null) {
      emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No user found'));
    } else {
      emit(state.copyWith(blocStatus: BlocStatus.success, user: user!));
    }
  }

  FutureOr<void> _fetchProfile(
    AuthFetchProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    late final Profile? profile;
    final eitherProfile = await _profileRepository.getCurrentProfile();
    eitherProfile.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => profile = success,
    );

    if (profile == null) {
      emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No profile found'));
    } else {
      emit(state.copyWith(blocStatus: BlocStatus.success, profile: profile!));
    }
  }

  FutureOr<void> _fetchUserAndProfile(
    AuthFetchUserAndProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    late final User? user;
    final eitherUser = _userRepository.getCurrentUser();
    eitherUser.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => user = success,
    );
    if (user == null) {
      emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No user found'));
      return;
    }

    late final Profile? profile;
    final eitherProfile = await _profileRepository.getCurrentProfile();
    eitherProfile.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => profile = success,
    );
    if (profile == null) {
      emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No profile found'));
      return;
    }

    emit(state.copyWith(blocStatus: BlocStatus.success, user: user, profile: profile));
  }

  FutureOr<void> _signOut(
    AuthSignOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherSignOut = await _userRepository.signOut();
    eitherSignOut.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(blocStatus: BlocStatus.success)),
    );
  }

  FutureOr<void> _editPrefTheme(
    AuthEditPrefTheme event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherEditPrefTheme = await _profileRepository.updateProfile(
        profile: event.profile.copyWith(prefTheme: event.prefTheme));
    eitherEditPrefTheme.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(blocStatus: BlocStatus.success)),
    );
  }

  FutureOr<void> _editPrefRole(
    AuthEditPrefRole event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherEditPrefRole = await _profileRepository.updateProfile(
        profile: event.profile.copyWith(prefContestRole: event.prefRole));
    eitherEditPrefRole.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(blocStatus: BlocStatus.success)),
    );
  }

  FutureOr<void> _editFullName(
    AuthEditFullName event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherEditFullName = await _profileRepository.updateProfile(
        profile: state.profile!.copyWith(fullName: event.fullName));
    eitherEditFullName.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(blocStatus: BlocStatus.success)),
    );
  }
}
