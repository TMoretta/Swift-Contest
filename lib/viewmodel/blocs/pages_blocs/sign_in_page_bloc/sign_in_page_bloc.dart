import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/model/repositories/crud_repositories/user_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'sign_in_page_event.dart';

part 'sign_in_page_state.dart';

class SignInPageBloc extends Bloc<SignInPageEvent, SignInPageState> {
  final UserRepository _userRepository;

  SignInPageBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(SignInPageState(status: BlocStatus.initial)) {
    on<SignInWithEmailAndPassword>(_signInWithEmailAndPassword);
    on<SignInWithEmail>(_signInWithEmail);
  }

  FutureOr<void> _signInWithEmailAndPassword(
    SignInWithEmailAndPassword event,
    Emitter<SignInPageState> emit,
  ) async {
    emit(SignInPageState(status: BlocStatus.loading,sourceEvent: event));

    final res = await _userRepository.signInWithEmailAndPassword(
        email: event.email, password: event.password);
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _signInWithEmail(
    SignInWithEmail event,
    Emitter<SignInPageState> emit,
  ) async {
    emit(SignInPageState(status: BlocStatus.loading,sourceEvent: event));

    final res = await _userRepository.signInWithEmail(email: event.email);
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
