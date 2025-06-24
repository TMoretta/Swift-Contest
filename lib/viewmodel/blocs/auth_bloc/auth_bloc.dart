import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/auth_bundle.dart';
import 'package:swift_contest/model/data_models/message.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/model/enums/app_theme.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/model/repositories/auth_repository.dart';
import 'package:swift_contest/viewmodel/enums/auth_status.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(AuthState(blocStatus: BlocStatus.initial, authStatus: AuthStatus.initial)) {
    on<AuthInit>(_init);
    on<AuthFetchUser>(_fetchUser);
    on<AuthFetchProfile>(_fetchProfile);
    on<AuthFetchProfileMessages>(_fetchProfileMessages);
    on<AuthFetchUserInfo>(_fetchUserInfo);
    on<AuthSignOut>(_signOut);
    on<AuthEditPrefTheme>(_editPrefTheme);
    on<AuthEditPrefRole>(_editPrefRole);
    on<AuthEditFullName>(_editFullName);
    on<AuthMarkMessageAsRead>(_markMessageAsRead);
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

    late final AuthBundle? authBundle;
    final eitherAuthBundle = await _authRepository.getUserInfo();
    eitherAuthBundle.fold(
      (failure) => emit(state.copyWith(
          blocStatus: BlocStatus.failure,
          authStatus: AuthStatus.initial,
          message: failure.message)),
      (success) => authBundle = success,
    );

    if (authBundle != null) {
      emit(state.copyWith(
        blocStatus: BlocStatus.success,
        authStatus: AuthStatus.authenticated,
        user: authBundle!.user,
        profile: authBundle!.profile,
        messages: authBundle!.messages,
      ));
    } else {
      emit(state.copyWith(blocStatus: BlocStatus.success, authStatus: AuthStatus.unauthenticated));
    }
  }

  FutureOr<void> _fetchUserInfo(
    AuthFetchUserInfo event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherAuthBundle = await _authRepository.getUserInfo();
    eitherAuthBundle.fold(
        (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
        (success) {
      if (success != null) {
        emit(state.copyWith(
            blocStatus: BlocStatus.success,
            user: success.user,
            profile: success.profile,
            messages: success.messages));
      } else {
        emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No user found'));
      }
    });
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
          emit(state.copyWith(blocStatus: BlocStatus.success, user: success));
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
          emit(state.copyWith(blocStatus: BlocStatus.success, profile: success));
        } else {
          emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No profile found'));
        }
      },
    );
  }

  FutureOr<void> _fetchProfileMessages(
    AuthFetchProfileMessages event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherProfile = await _authRepository.getCurrentProfileMessages();
    eitherProfile.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(blocStatus: BlocStatus.success, messages: success)),
    );
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
          emit(state.copyWith(blocStatus: BlocStatus.success, authStatus: AuthStatus.initial)),
    );
  }

  FutureOr<void> _editPrefTheme(
    AuthEditPrefTheme event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final profile = state.profile;
    if (profile == null) {
      emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No user is authenticated'));
      return;
    }

    final eitherEditPrefTheme =
        await _authRepository.updateProfilePrefTheme(prefTheme: event.prefTheme);
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

    final profile = state.profile;
    if (profile == null) {
      emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No user is authenticated'));
      return;
    }

    final eitherEditPrefRole =
        await _authRepository.updateProfilePrefRole(prefRole: event.prefRole);
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

    final profile = state.profile;
    if (profile == null) {
      emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'No user is authenticated'));
      return;
    }

    final eitherEditFullName =
        await _authRepository.updateProfileFullName(fullName: event.fullName);
    eitherEditFullName.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(blocStatus: BlocStatus.success)),
    );
  }

  FutureOr<void> _markMessageAsRead(
    AuthMarkMessageAsRead event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherMarkMessageAsRead =
        await _authRepository.markMessageAsRead(messageId: event.messageId);
    eitherMarkMessageAsRead.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(blocStatus: BlocStatus.success)),
    );
  }
}
