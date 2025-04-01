import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/model/data_models/user/user.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/user_repository.dart';

part 'sign_in_page_event.dart';

part 'sign_in_page_state.dart';

class SignInPageBloc extends Bloc<SignInPageEvent, SignInPageState> {
  final UserRepository _userRepository;

  SignInPageBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SignInPageState(status: BlocStatus.initial)) {
    on<SignInPageSignInWithEmailAndPassword>(_signInWithEmailAndPassword);
  }

  Future<void> _signInWithEmailAndPassword(
    SignInPageSignInWithEmailAndPassword event,
    Emitter<SignInPageState> emit,
  ) async {
    emit(SignInPageState(status: BlocStatus.loading));
    final res = await _userRepository.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );
    res.fold(
      (failure) => emit(SignInPageState(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(SignInPageState(status: BlocStatus.success, user: success)),
    );
  }
}
