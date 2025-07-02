import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/model/bundles/simple_juror_and_voting_session_bundle.dart';
import 'package:swift_contest/model/repositories/auth_repository.dart';
import 'package:swift_contest/model/repositories/juror_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'sign_in_page_event.dart';

part 'sign_in_page_state.dart';

class SignInPageBloc extends Bloc<SignInPageEvent, SignInPageState> {
  final AuthRepository _authRepository;
  final JurorRepository _jurorRepository;

  SignInPageBloc({
    required AuthRepository authRepository,
    required JurorRepository jurorRepository,
  })  : _authRepository = authRepository,
        _jurorRepository = jurorRepository,
        super(SignInPageState(status: BlocStatus.initial)) {
    on<SignInWithEmailAndPassword>(_signInWithEmailAndPassword);
    on<SignInWithEmail>(_signInWithEmail);
    on<SignInPageVoteAsSimpleJuror>(_voteAsSimpleJuror);
  }

  FutureOr<void> _signInWithEmailAndPassword(
    SignInWithEmailAndPassword event,
    Emitter<SignInPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final res = await _authRepository.signInWithEmailAndPassword(
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
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final res = await _authRepository.signInWithEmail(email: event.email);
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  //* Vote as simple juror
  FutureOr<void> _voteAsSimpleJuror(
    SignInPageVoteAsSimpleJuror event,
    Emitter<SignInPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherJoinContest = await _jurorRepository.accessVotingAsSimpleJuror(
        fullName: event.fullName, token: event.token);
    eitherJoinContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(
          state.copyWith(status: BlocStatus.success, simpleJurorAndVotingSessionBundle: success)),
    );
  }
}
