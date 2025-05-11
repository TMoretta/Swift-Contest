import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';

part 'contest_role_event.dart';

part 'contest_role_state.dart';

class ContestRoleBloc extends Bloc<ContestRoleEvent, ContestRoleState> {
  final ProfileRepository _profileRepository;

  ContestRoleBloc({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(ContestRoleState(status: BlocStatus.initial)) {
    on<ContestRoleInitRole>(_contestRoleInit);
    on<ContestRoleChangeRole>(_contestRoleChange);
    on<ContestRoleTriggerListener>(_contestRoleTriggerListener);
    on<ContestRoleClear>(_clear);
  }

  Future<void> _contestRoleInit(
    ContestRoleInitRole event,
    Emitter<ContestRoleState> emit,
  ) async {
    emit(ContestRoleState(status: BlocStatus.loading));
    final res = await _profileRepository.getCurrentProfile();
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (profile) =>
          emit(state.copyWith(status: BlocStatus.success, contestRole: profile.prefContestRole)),
    );
  }

  void _contestRoleChange(
    ContestRoleChangeRole event,
    Emitter<ContestRoleState> emit,
  ) {
    emit(state.copyWith(status: BlocStatus.success, contestRole: event.contestRole));
  }

  void _contestRoleTriggerListener(
    ContestRoleTriggerListener event,
    Emitter<ContestRoleState> emit,
  ) {
    final currentState = state;
    emit(state.copyWith(status: BlocStatus.loading));
    emit(currentState);
  }

  void _clear(
    ContestRoleClear event,
    Emitter<ContestRoleState> emit,
  ) {
    emit(ContestRoleState(status: BlocStatus.initial));
  }
}
