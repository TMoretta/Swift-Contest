import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/auth_bundle.dart';
import 'package:swift_contest/model/enums/app_theme.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/model/repositories/auth_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/profile_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/user_repository.dart';
import 'package:swift_contest/viewmodel/enums/auth_status.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  AuthBloc({
    required ProfileRepository profileRepository,
    required AuthRepository authRepository,
  })  :
        _profileRepository = profileRepository,
        _authRepository = authRepository,
        super(AuthState(blocStatus: BlocStatus.initial, authStatus: AuthStatus.initial)) {
    on<AuthInit>(_init);
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
    emit(state.copyWith(
        blocStatus: BlocStatus.loading, sourceEvent: event, authStatus: AuthStatus.initial));

    if (event.delay != 0) {
      await Future.delayed(Duration(seconds: event.delay));
    }

    final eitherAuthBundle = await _authRepository.getCurrentUserAndProfile();
    eitherAuthBundle.fold(
        (failure) => emit(state.copyWith(
            blocStatus: BlocStatus.failure,
            authStatus: AuthStatus.initial,
            message: failure.message)), (success) {
      if (success != null) {
        emit(state.copyWith(
            blocStatus: BlocStatus.success,
            authStatus: AuthStatus.authenticated,
            authBundle: success));
      } else {
        emit(
            state.copyWith(blocStatus: BlocStatus.success, authStatus: AuthStatus.unauthenticated));
      }
    });

    // late final User? user;
    // final eitherUser = _userRepository.getCurrentUser();
    // eitherUser.fold(
    //   (failure) => emit(state.copyWith(
    //       blocStatus: BlocStatus.initial,
    //       authStatus: AuthStatus.initial,
    //       message: failure.message)),
    //   (success) => user = success,
    // );
    // if (eitherUser.isLeft()) {
    //   return;
    // }
    // if (user == null) {
    //   emit(state.copyWith(blocStatus: BlocStatus.success, authStatus: AuthStatus.unauthenticated));
    //   return;
    // }
    //
    // late final Profile? profile;
    // final eitherProfile = await _profileRepository.getProfileById(id: user!.id);
    // eitherProfile.fold(
    //   (failure) => emit(state.copyWith(
    //       blocStatus: BlocStatus.failure,
    //       authStatus: AuthStatus.authenticated,
    //       user: user,
    //       message: failure.message)),
    //   (success) => profile = success,
    // );
    // if (eitherProfile.isLeft()) {
    //   return;
    // }
    // if (profile == null) {
    //   emit(state.copyWith(
    //       blocStatus: BlocStatus.failure,
    //       authStatus: AuthStatus.authenticated,
    //       message: 'Profile not found'));
    //   return;
    // }
    //
    // emit(state.copyWith(
    //   blocStatus: BlocStatus.success,
    //   authStatus: AuthStatus.authenticated,
    //   user: user,
    //   profile: profile,
    // ));
  }

  FutureOr<void> _fetchUser(
    AuthFetchUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherUser = await _authRepository.getCurrentUser();
    eitherUser.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) {
        if (success != null) {
          emit(state.copyWith(
              blocStatus: BlocStatus.success,
              authBundle: state.authBundle!.copyWith(user: success)));
        } else {
          emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No user found'));
        }
      },
    );
  }

  FutureOr<void> _fetchProfile(
    AuthFetchProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherProfile = await _authRepository.getCurrentProfile();
    eitherProfile.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) {
        if (success != null) {
          emit(state.copyWith(
              blocStatus: BlocStatus.success,
              authBundle: state.authBundle!.copyWith(profile: success)));
        } else {
          emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No profile found'));
        }
      },
    );

    // late final Profile? profile;
    // final eitherProfile = await _profileRepository.getCurrentProfile();
    // eitherProfile.fold(
    //   (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
    //   (success) => profile = success,
    // );
    //
    // if (profile == null) {
    //   emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No profile found'));
    // } else {
    //   emit(state.copyWith(blocStatus: BlocStatus.success, profile: profile!));
    // }
  }

  FutureOr<void> _fetchUserAndProfile(
    AuthFetchUserAndProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherAuthBundle = await _authRepository.getCurrentUserAndProfile();
    eitherAuthBundle.fold(
        (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
        (success) {
      if (success != null) {
        emit(state.copyWith(blocStatus: BlocStatus.success, authBundle: success));
      } else {
        emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No user found'));
      }
    });

    // late final User? user;
    // final eitherUser = _userRepository.getCurrentUser();
    // eitherUser.fold(
    //   (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
    //   (success) => user = success,
    // );
    // if (user == null) {
    //   emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No user found'));
    //   return;
    // }
    //
    // late final Profile? profile;
    // final eitherProfile = await _profileRepository.getCurrentProfile();
    // eitherProfile.fold(
    //   (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
    //   (success) => profile = success,
    // );
    // if (profile == null) {
    //   emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No profile found'));
    //   return;
    // }
    //
    // emit(state.copyWith(blocStatus: BlocStatus.success, user: user, profile: profile));
  }

  FutureOr<void> _signOut(
    AuthSignOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherSignOut = await _authRepository.signOut();
    eitherSignOut.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) =>
          emit(state.copyWith(blocStatus: BlocStatus.success,authStatus: AuthStatus.initial)),
    );
  }

  FutureOr<void> _editPrefTheme(
    AuthEditPrefTheme event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final profile = state.authBundle?.profile;
    if(profile == null) {
      emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No user is authenticated'));
      return;
    }

    final eitherEditPrefTheme = await _profileRepository.updateProfile(
        profile: profile.copyWith(prefTheme: event.prefTheme));
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

    final profile = state.authBundle?.profile;
    if(profile == null) {
      emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No user is authenticated'));
      return;
    }

    final eitherEditPrefRole = await _profileRepository.updateProfile(
        profile: profile.copyWith(prefContestRole: event.prefRole));
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

    final profile = state.authBundle?.profile;
    if(profile == null) {
      emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No user is authenticated'));
      return;
    }

    final eitherEditFullName = await _profileRepository.updateProfile(
        profile: profile.copyWith(fullName: event.fullName));
    eitherEditFullName.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(blocStatus: BlocStatus.success)),
    );
  }
}
