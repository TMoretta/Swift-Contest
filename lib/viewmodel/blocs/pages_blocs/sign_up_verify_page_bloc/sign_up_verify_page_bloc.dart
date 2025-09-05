import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/repositories/auth_repository.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'sign_up_verify_page_event.dart';
part 'sign_up_verify_page_state.dart';

class SignUpVerifyPageBloc extends Bloc<SignUpVerifyPageEvent, SignUpVerifyPageState> {
  final AuthRepository _authRepository;

  SignUpVerifyPageBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(SignUpVerifyPageState(status: BlocStatus.initial)) {
    on<SignUpVerifyOtp>(_verifyOtp);
  }

  FutureOr<void> _verifyOtp(
    SignUpVerifyOtp event,
    Emitter<SignUpVerifyPageState> emit,
  ) async {
    emit(SignUpVerifyPageState(status: BlocStatus.loading, sourceEvent: event));

    final res = await _authRepository.signUpVerifyOtp(email: event.email, otp: event.otp);
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
