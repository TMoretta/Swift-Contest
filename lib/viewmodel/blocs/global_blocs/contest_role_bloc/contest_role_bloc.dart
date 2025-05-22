// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:swift_contest/model/enums/contest_role.dart';
// import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
// import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
//
// part 'contest_role_event.dart';
// part 'contest_role_state.dart';
//
// class ContestRoleBloc extends Bloc<ContestRoleEvent, ContestRoleState> {
//   final ProfileRepository _profileRepository;
//
//   ContestRoleBloc({required ProfileRepository profileRepository})
//       : _profileRepository = profileRepository,
//         super(ContestRoleState(status: BlocStatus.initial)) {
//     on<ContestRoleChangeRole>(_changeRole);
//     on<ContestRoleClear>(_clear);
//     // on<ContestRoleInitRole>(_initRole);
//     // on<ContestRoleTriggerListener>(_contestRoleTriggerListener);
//   }
//
//   void _changeRole(
//       ContestRoleChangeRole event,
//       Emitter<ContestRoleState> emit,
//       ) {
//     emit(state.copyWith(status: BlocStatus.success, contestRole: event.contestRole));
//   }
//
//   void _clear(
//       ContestRoleClear event,
//       Emitter<ContestRoleState> emit,
//       ) {
//     emit(ContestRoleState(status: BlocStatus.initial));
//   }
//
//   // Future<void> _initRole(
//   //   ContestRoleInitRole event,
//   //   Emitter<ContestRoleState> emit,
//   // ) async {
//   //   emit(ContestRoleState(status: BlocStatus.loading));
//   //   final res = await _profileRepository.getCurrentProfile();
//   //   res.fold(
//   //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
//   //     (profile) =>
//   //         emit(state.copyWith(status: BlocStatus.success, contestRole: profile.prefContestRole)),
//   //   );
//   // }
//
//
//
//   // void _contestRoleTriggerListener(
//   //   ContestRoleTriggerListener event,
//   //   Emitter<ContestRoleState> emit,
//   // ) {
//   //   final currentState = state;
//   //   emit(state.copyWith(status: BlocStatus.loading));
//   //   emit(currentState);
//   // }
//
//
// }
