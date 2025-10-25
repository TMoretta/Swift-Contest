import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/model/database/repositories/auth_repository.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'sign_in_verify_page_event.dart';

part 'sign_in_verify_page_state.dart';

class SignInVerifyPageBloc extends Bloc<SignInVerifyPageEvent, SignInVerifyPageState> {
  final AuthRepository _authRepository;

  SignInVerifyPageBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const SignInVerifyPageState(status: BlocStatus.initial)) {
    on<SignInVerifyOtp>(_verifyOtp);
  }

  FutureOr<void> _verifyOtp(
    SignInVerifyOtp event,
    Emitter<SignInVerifyPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final res = await _authRepository.signInVerifyOtp(email: event.email, otp: event.otp);
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
