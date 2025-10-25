import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:swift_contest/model/database/entities/account.dart';
import 'package:swift_contest/model/database/entities/message.dart';
import 'package:swift_contest/model/database/entities/profile.dart';
import 'package:swift_contest/model/database/repositories/auth_repository.dart';
import 'package:swift_contest/model/database/types/contest_role.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/viewmodel/types/auth_status.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState(blocStatus: BlocStatus.initial, authStatus: AuthStatus.initial)) {
    on<AuthFetch>(_fetch);
    on<AuthSignOut>(_signOut);
    on<AuthDeleteAccount>(_deleteAccount);
    on<AuthEditPrefRole>(_editPrefRole);
    on<AuthEditFullName>(_editFullName);
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      return AuthState.fromJson(json);
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    try {
      return state.toJson();
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  //* fetch
  FutureOr<void> _fetch(
    AuthFetch event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
        blocStatus: BlocStatus.loading, authStatus: AuthStatus.initial, sourceEvent: event));
    final eitherAuthBundle = await _authRepository.getAccountBundle();
    eitherAuthBundle.fold(
      (failure) => emit(state.copyWith(
          blocStatus: BlocStatus.failure,
          authStatus: AuthStatus.unauthenticated,
          message: failure.message)),
      (success) {
        if (success == null) {
          emit(state.copyWith(
            blocStatus: BlocStatus.success,
            authStatus: AuthStatus.unauthenticated,
            isInitialized: true,
          ));
        } else {
          emit(state.copyWith(
            blocStatus: BlocStatus.success,
            authStatus: AuthStatus.authenticated,
            isInitialized: true,
            account: success.account,
            profile: success.profile,
          ));
        }
      },
    );
  }

  FutureOr<void> _signOut(
    AuthSignOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherSignOut = await _authRepository.signOut();
    eitherSignOut.fold(
        (failure) async =>
            emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
        (success) async {
      emit(AuthState(
        blocStatus: BlocStatus.success,
        sourceEvent: event,
        authStatus: AuthStatus.unauthenticated,
      ));
      await HydratedBloc.storage.clear();
    });
  }

  FutureOr<void> _editPrefRole(
    AuthEditPrefRole event,
    Emitter<AuthState> emit,
  ) async {
    if(state.profile!.prefRole == event.prefRole) {
      return;
    }

    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherEditPrefRole =
        await _authRepository.updateProfilePrefRole(prefRole: event.prefRole);
    eitherEditPrefRole.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) {
        final updatedProfile = state.profile!.copyWith(prefRole: event.prefRole);
        emit(state.copyWith(blocStatus: BlocStatus.success, profile: updatedProfile));
      },
    );
  }

  FutureOr<void> _editFullName(
    AuthEditFullName event,
    Emitter<AuthState> emit,
  ) async {
    if(state.profile!.fullName == event.fullName) {
      return;
    }

    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherEditFullName =
        await _authRepository.updateProfileFullName(fullName: event.fullName);
    eitherEditFullName.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) {
        final updatedProfile = state.profile!.copyWith(fullName: event.fullName);
        emit(state.copyWith(blocStatus: BlocStatus.success, profile: updatedProfile));
      },
    );
  }

  FutureOr<void> _deleteAccount(
    AuthDeleteAccount event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherDeleteUser = await _authRepository.deleteAccount();
    eitherDeleteUser.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(blocStatus: BlocStatus.success)),
    );
  }
}
