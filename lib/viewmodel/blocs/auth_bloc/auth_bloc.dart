import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:swift_contest/model/bundles/user_auth_bundle.dart';
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

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(AuthState(blocStatus: BlocStatus.initial, authStatus: AuthStatus.initial)) {
    on<AuthInit>(_init);
    on<AuthRefresh>(_refresh);
    on<AuthFetchUser>(_fetchUser);
    on<AuthFetchProfile>(_fetchProfile);
    on<AuthFetchProfileMessages>(_fetchProfileMessages);
    on<AuthFetchUserInfo>(_fetchUserInfo);
    on<AuthSignOut>(_signOut);
    on<AuthDeleteAccount>(_deleteAccount);
    on<AuthEditPrefRole>(_editPrefRole);
    on<AuthEditFullName>(_editFullName);
    on<AuthMarkMessageAsRead>(_markMessageAsRead);
    on<AuthDeleteMessage>(_deleteMessage);
    on<AuthDeleteAllMessages>(_deleteAllMessages);
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

    late final UserAuthBundle? authBundle;
    final eitherAuthBundle = await _authRepository.getCurrentUserAuthBundle();
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

  FutureOr<void> _refresh(
      AuthRefresh event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(
        blocStatus: BlocStatus.loading, sourceEvent: event, authStatus: AuthStatus.initial));

    late final UserAuthBundle? authBundle;
    final eitherAuthBundle = await _authRepository.getCurrentUserAuthBundle();
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

    final eitherAuthBundle = await _authRepository.getCurrentUserAuthBundle();
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

  FutureOr<void> _editPrefRole(
    AuthEditPrefRole event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

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
      (success) {
        final updatedMessages = state.messages!.map((e) {
          if (e.id == success.id) {
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

  FutureOr<void> _deleteAllMessages(AuthDeleteAllMessages event, Emitter<AuthState> emit,) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading, sourceEvent: event));

    final eitherDeleteAllMessages = await _authRepository.deleteAllProfileMessages(profileId: event.profileId);
    eitherDeleteAllMessages.fold(
          (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
          (success) => emit(state.copyWith(blocStatus: BlocStatus.success,messages: [])),
    );
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      return AuthState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    try {
      return state.toJson();
    } catch (_) {
      return null;
    }
  }
}
