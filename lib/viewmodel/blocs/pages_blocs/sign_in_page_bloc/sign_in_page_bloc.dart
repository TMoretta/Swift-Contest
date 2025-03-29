import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/user/user.dart';
import 'package:swift_contest/viewmodel/repositories/user_repository.dart';
import 'package:swift_contest/viewmodel/utils/bloc_status.dart';

part 'sign_in_page_event.dart';
part 'sign_in_page_state.dart';

class SignInPageBloc extends Bloc<SignInPageEvent, SignInPageState> {
  final UserRepository _userRepository;

  SignInPageBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SignInPageInitial()) {
    on<SignInPageSignInWithEmailAndPassword>(_signInWithEmailAndPassword);
  }

  Future<void> _signInWithEmailAndPassword(
    SignInPageSignInWithEmailAndPassword event,
    Emitter<SignInPageState> emit,
  ) async {
    emit(SignInPageLoading());
    final res = await _userRepository.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );
    res.fold(
      (failure) => emit(SignInPageFailure(message: failure.message)),
      (success) => emit(SignInPageSuccess(user: success)),
    );
  }
}
