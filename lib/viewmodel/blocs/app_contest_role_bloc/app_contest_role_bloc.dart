import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/profile/contest_role.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';

part 'app_contest_role_event.dart';
part 'app_contest_role_state.dart';

class AppContestRoleBloc extends Bloc<AppContestRoleEvent, AppContestRoleState> {
  final ProfileRepository _profileRepository;

  AppContestRoleBloc({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(AppContestRoleInitial()) {
    on<AppContestRoleInitRole>(_appContestRoleInit);
    on<AppContestRoleChangeRole>(_appContestRoleChange);
    on<AppContestRoleTriggerListener>(_appContestRoleTriggerListener);
  }

  Future<void> _appContestRoleInit(
    AppContestRoleInitRole event,
    Emitter<AppContestRoleState> emit,
  ) async {
    emit(AppContestRoleLoading());
    final res = await _profileRepository.getCurrentProfile();
    res.fold(
      (failure) => emit(AppContestRoleFailure(message: failure.message)),
      (profile) => emit(AppContestRoleSuccess(appContestRole: profile.prefContestRole)),
    );
  }

  void _appContestRoleChange(
    AppContestRoleChangeRole event,
    Emitter<AppContestRoleState> emit,
  ) {
    emit(AppContestRoleLoading());
    emit(AppContestRoleSuccess(appContestRole: event.contestRole));
  }

  void _appContestRoleTriggerListener(
    AppContestRoleTriggerListener event,
    Emitter<AppContestRoleState> emit,
  ) {
    final currentState = state;
    emit(AppContestRoleLoading());
    emit(currentState);
  }
}
