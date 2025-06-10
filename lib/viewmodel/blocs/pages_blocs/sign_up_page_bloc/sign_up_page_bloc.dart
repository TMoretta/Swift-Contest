import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/model/repositories/crud_repositories/user_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'sign_up_page_event.dart';
part 'sign_up_page_state.dart';

class SignUpPageBloc extends Bloc<SignUpPageEvent, SignUpPageState> {
  final UserRepository _userRepository;
  SignUpPageBloc({
    required UserRepository userRepository,
}) : _userRepository = userRepository, super(SignUpPageState(status: BlocStatus.initial)) {
    on<SignUpWithEmailAndPassword>(_signUpWithEmailAndPassword);
    on<SignUpWithEmail>(_signUpWithEmail);
  }

  FutureOr<void> _signUpWithEmailAndPassword(
      SignUpWithEmailAndPassword event,
      Emitter<SignUpPageState> emit,
      ) async {
    emit(SignUpPageState(status: BlocStatus.loading, sourceEvent: event));

    final res = await _userRepository.signUpWithEmailAndPassword(
        email: event.email, password: event.password,fullName: event.fullName);
    res.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _signUpWithEmail(
      SignUpWithEmail event,
      Emitter<SignUpPageState> emit,
      ) async {
    emit(SignUpPageState(status: BlocStatus.loading,sourceEvent: event));

    final res = await _userRepository.signUpWithEmail(email: event.email,fullName: event.fullName);
    res.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
