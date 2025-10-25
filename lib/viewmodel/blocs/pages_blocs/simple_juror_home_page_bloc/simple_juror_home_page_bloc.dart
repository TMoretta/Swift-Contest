import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/entities/voting_session.dart';
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
        super(const SimpleJurorHomePageState(status: BlocStatus.initial)) {
    on<SimpleJurorHomePageSignOut>(_signOut);
    on<SimpleJurorHomePageAccessVoting>(_accessVoting);
  }

  FutureOr<void> _signOut(
    SimpleJurorHomePageSignOut event,
    Emitter<SimpleJurorHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    // It is an anonymous user. At sign out it will be deleted
    final res = await _authRepository.deleteAccount();
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _accessVoting(
      SimpleJurorHomePageAccessVoting event,
      Emitter<SimpleJurorHomePageState> emit,
      ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final res = await _jurorRepository.accessVotingAsSimpleJuror(token: event.token);
    res.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => emit(state.copyWith(status: BlocStatus.success, votingSession: success)),
    );
  }
}
