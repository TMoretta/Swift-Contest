import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/bundles/auth_bundle.dart';
import 'package:swift_contest/model/database/entities/account.dart';
import 'package:swift_contest/model/database/entities/message.dart';
import 'package:swift_contest/model/database/entities/profile.dart';
import 'package:swift_contest/model/database/repositories/auth_repository.dart';
import 'package:swift_contest/model/database/types/contest_role.dart';
import 'package:swift_contest/utils/logger/logger.dart';
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
    on<AuthFetch>(_fetch);
    on<AuthSignOut>(_signOut);
    on<AuthDeleteAccount>(_deleteAccount);
    on<AuthEditPrefRole>(_editPrefRole);
    on<AuthEditFullName>(_editFullName);
    on<AuthMarkMessageAsRead>(_markMessageAsRead);
    on<AuthDeleteMessage>(_deleteMessage);
    on<AuthDeleteAllMessages>(_deleteAllMessages);
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
  FutureOr<void> _init(
    AuthInit event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    if (event.delay != 0) {
      await Future.delayed(Duration(seconds: event.delay));
    }

    late final bool isAuthenticated;
    final eitherExists = await _authRepository.isCurrentUserAuthenticated();
    eitherExists.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => isAuthenticated = success,
    );
    if (eitherExists.isLeft()) {
      return;
    }

    if (!isAuthenticated) {
      emit(state.copyWith(
          blocStatus: BlocStatus.success,
          isInitialized: true,
          authStatus: AuthStatus.unauthenticated));
      return;
    }

    late final AuthBundle authBundle;
    final eitherAuthBundle = await _authRepository.getCurrentAccountAuthBundle();
    eitherAuthBundle.fold(
      (failure) => emit(state.copyWith(
          blocStatus: BlocStatus.failure,
          authStatus: AuthStatus.initial,
          message: failure.message)),
      (success) => authBundle = success,
    );
    if (eitherAuthBundle.isLeft()) {
      return;
    }

    emit(state.copyWith(
      blocStatus: BlocStatus.success,
      isInitialized: true,
      authStatus: AuthStatus.authenticated,
      account: authBundle.account,
      profile: authBundle.profile,
      messages: authBundle.messages,
    ));
  }

  //* fetch
  FutureOr<void> _fetch(
    AuthFetch event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    late final AuthBundle authBundle;
    final eitherAuthBundle = await _authRepository.getCurrentAccountAuthBundle();
    eitherAuthBundle.fold(
      (failure) => emit(state.copyWith(
          blocStatus: BlocStatus.failure,
          authStatus: AuthStatus.initial,
          message: failure.message)),
      (success) => authBundle = success,
    );
    if (eitherAuthBundle.isLeft()) {
      return;
    }

    emit(state.copyWith(
      blocStatus: BlocStatus.success,
      isInitialized: true,
      authStatus: AuthStatus.authenticated,
      account: authBundle.account,
      profile: authBundle.profile,
      messages: authBundle.messages,
    ));
  }

  FutureOr<void> _signOut(
    AuthSignOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherSignOut = await _authRepository.signOut();
    eitherSignOut.fold(
      (failure) async => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) async {
        emit(state.copyWith(blocStatus: BlocStatus.success, authStatus: AuthStatus.initial));
        // await HydratedBloc.storage.clear();
      }
    );
  }

  FutureOr<void> _editPrefRole(
    AuthEditPrefRole event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherEditPrefRole =
        await _authRepository.updateCurrentProfilePrefRole(prefRole: event.prefRole);
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

    final eitherEditFullName =
        await _authRepository.updateCurrentProfileFullName(fullName: event.fullName);
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
      (success) {
        final updatedMessages = state.messages!.map((e) {
          if (e.id == event.messageId) {
            e = e.copyWith(isRead: true);
          }
          return e;
        }).toList(growable: false);
        emit(state.copyWith(blocStatus: BlocStatus.success, messages: updatedMessages));
      },
    );
  }

  FutureOr<void> _deleteAccount(
    AuthDeleteAccount event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherDeleteUser = await _authRepository.deleteCurrentAccount();
    eitherDeleteUser.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(blocStatus: BlocStatus.success)),
    );
  }

  FutureOr<void> _deleteMessage(
    AuthDeleteMessage event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherDeleteMessage = await _authRepository.deleteMessage(messageId: event.messageId);
    eitherDeleteMessage.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) {
        final List<Message> updatedMessages = [];
        updatedMessages.addAll(state.messages!);
        updatedMessages.remove(updatedMessages.firstWhere((e) => e.id == event.messageId));
        emit(state.copyWith(blocStatus: BlocStatus.success, messages: updatedMessages));
      },
    );
  }

  FutureOr<void> _deleteAllMessages(
    AuthDeleteAllMessages event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherDeleteAllMessages = await _authRepository.deleteAllCurrentAccountMessages();
    eitherDeleteAllMessages.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(blocStatus: BlocStatus.success, messages: [])),
    );
  }
}
