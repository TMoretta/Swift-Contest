import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/model/data_models/user/user.dart';
import 'package:swift_contest/viewmodel/repositories/user_repository.dart';

part 'sign_up_page_event.dart';
part 'sign_up_page_state.dart';

class SignUpPageBloc extends Bloc<SignUpPageEvent, SignUpPageState> {
  final UserRepository _userRepository;

  SignUpPageBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SignUpPageInitial()) {
    on<SignUpPageSignUpWithEmailAndPassword>(_signUpWithEmailAndPassword);
  }

  Future<void> _signUpWithEmailAndPassword(
      SignUpPageSignUpWithEmailAndPassword event,
      Emitter<SignUpPageState> emit,
      ) async {
    emit(SignUpPageLoading());
    final res = await _userRepository.signUpWithEmailAndPassword(
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      lastName: event.lastName,
    );
    res.fold(
          (failure) => emit(SignUpPageFailure(message: failure.message)),
          (success) => emit(SignUpPageSuccess(user: success)),
    );
  }
}
