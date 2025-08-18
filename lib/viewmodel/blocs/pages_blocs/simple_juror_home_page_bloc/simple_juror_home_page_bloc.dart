import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/repositories/auth_repository.dart';
import 'package:swift_contest/model/database/repositories/juror_repository.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'simple_juror_home_page_event.dart';

part 'simple_juror_home_page_state.dart';

class SimpleJurorHomePageBloc extends Bloc<SimpleJurorHomePageEvent, SimpleJurorHomePageState> {
  final AuthRepository _authRepository;
  final JurorRepository _jurorRepository;

  SimpleJurorHomePageBloc({
    required AuthRepository authRepository,
    required JurorRepository jurorRepository,
  })  : _authRepository = authRepository,
        _jurorRepository = jurorRepository,
        super(SimpleJurorHomePageState(status: BlocStatus.initial)) {
    on<SimpleJurorHomePageSignOut>(_signOut);
  }

  FutureOr<void> _signOut(
    SimpleJurorHomePageSignOut event,
    Emitter<SimpleJurorHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final res = await _authRepository.signOut();
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
