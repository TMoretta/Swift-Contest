import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:swift_contest/model/database/repositories/auth_repository.dart';
import 'package:swift_contest/model/database/repositories/auth_repository_.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'sign_in_verify_page_event.dart';

part 'sign_in_verify_page_state.dart';

class SignInVerifyPageBloc extends HydratedBloc<SignInVerifyPageEvent, SignInVerifyPageState> {
  final AuthRepository _authRepository;

  SignInVerifyPageBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(SignInVerifyPageState(status: BlocStatus.initial)) {
    on<SignInVerifyOtp>(_verifyOtp);
  }

  @override
  SignInVerifyPageState? fromJson(Map<String, dynamic> json) {
    try {
      return SignInVerifyPageState.fromJson(json);
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SignInVerifyPageState state) {
    try {
      return state.toJson();
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  FutureOr<void> _verifyOtp(
    SignInVerifyOtp event,
    Emitter<SignInVerifyPageState> emit,
  ) async {
    emit(SignInVerifyPageState(status: BlocStatus.loading,sourceEvent: event));

    final res = await _authRepository.signInVerifyOtp(email: event.email, otp: event.otp);
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
