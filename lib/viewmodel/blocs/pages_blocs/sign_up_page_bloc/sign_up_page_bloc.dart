import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/user_repository.dart';

part 'sign_up_page_event.dart';

part 'sign_up_page_state.dart';

class SignUpPageBloc extends Bloc<SignUpPageEvent, SignUpPageState> {
  final UserRepository _userRepository;

  SignUpPageBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SignUpPageState(status: BlocStatus.initial)) {
    on<SignUpPageSignUpWithEmailAndPassword>(_signUpWithEmailAndPassword);
  }

  Future<void> _signUpWithEmailAndPassword(
    SignUpPageSignUpWithEmailAndPassword event,
    Emitter<SignUpPageState> emit,
  ) async {
    emit(SignUpPageState(status: BlocStatus.loading));
    final res = await _userRepository.signUpWithEmailAndPassword(
      email: event.email,
      password: event.password,
      fullName: event.fullName,
    );
    res.fold(
      (failure) => emit(SignUpPageState(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(SignUpPageState(status: BlocStatus.success, user: success)),
    );
  }
}
