import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/repositories/auth_repository.dart';
import 'package:swift_contest/utils/functions/save_and_launch_file.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'sign_up_page_event.dart';

part 'sign_up_page_state.dart';

class SignUpPageBloc extends Bloc<SignUpPageEvent, SignUpPageState> {
  final AuthRepository _authRepository;

  SignUpPageBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(SignUpPageState(status: BlocStatus.initial)) {
    on<SignUpWithEmailAndPassword>(_signUpWithEmailAndPassword);
    on<SignUpWithEmail>(_signUpWithEmail);
    on<SignUpPageAuthenticateSimpleJuror>(_authenticateSimpleJuror);
    on<SignUpPageDownloadLatestApk>(_downloadLatestApk);
  }

  FutureOr<void> _signUpWithEmailAndPassword(
    SignUpWithEmailAndPassword event,
    Emitter<SignUpPageState> emit,
  ) async {
    emit(SignUpPageState(status: BlocStatus.loading, sourceEvent: event));

    final res = await _authRepository.signUpWithEmailAndPassword(
        email: event.email, password: event.password, fullName: event.fullName);
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _signUpWithEmail(
    SignUpWithEmail event,
    Emitter<SignUpPageState> emit,
  ) async {
    emit(SignUpPageState(status: BlocStatus.loading, sourceEvent: event));

    final res = await _authRepository.signUpWithEmail(email: event.email, fullName: event.fullName);
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _authenticateSimpleJuror(
    SignUpPageAuthenticateSimpleJuror event,
    Emitter<SignUpPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final res = await _authRepository.anonSignIn(
      fullName: event.fullName,
    );
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _downloadLatestApk(
    SignUpPageDownloadLatestApk event,
    Emitter<SignUpPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherBytes = await _authRepository.getLatestApk();

    await eitherBytes.fold(
      (failure) async {
        emit(state.copyWith(status: BlocStatus.failure, message: failure.message));
      },
      (fileBytes) async {
        // The saveAndLaunchFile function returns a tuple indicating success and a message.
        final (isSuccess, message) = await saveAndLaunchFile(fileBytes, 'app-release.apk');
        if (isSuccess) {
          // On success, we still want to show the message from saveAndLaunchFile.
          emit(state.copyWith(status: BlocStatus.success, message: message));
        } else {
          // On failure, emit a failure state with the corresponding message.
          emit(state.copyWith(status: BlocStatus.failure, message: message));
        }
      },
    );
  }
}
