// import 'dart:async';
//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:swift_contest/model/data_models/profile.dart';
// import 'package:swift_contest/model/repositories/crud_repositories/profile_repository.dart';
// import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
//
// part 'account_page_event.dart';
//
// part 'account_page_state.dart';
//
// class AccountPageBloc extends Bloc<AccountPageEvent, AccountPageState> {
//   final ProfileRepository _profileRepository;
//
//   AccountPageBloc({
//     required ProfileRepository profileRepository,
//   })  : _profileRepository = profileRepository,
//         super(AccountPageState(status: BlocStatus.initial)) {
//     on<AccountPageEditFullName>(_editFullName);
//   }
//
//   FutureOr<void> _editFullName(
//     AccountPageEditFullName event,
//     Emitter<AccountPageState> emit,
//   ) async {
//     emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));
//
//     late final Profile? profile;
//     final eitherProfile = await _profileRepository.getCurrentProfile();
//     eitherProfile.fold(
//       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
//       (success) => profile = success,
//     );
//     if (eitherProfile.isLeft()) {
//       return;
//     }
//     if(profile == null) {
//       emit(state.copyWith(status: BlocStatus.failure, message: 'Profile not found'));
//       return;
//     }
//
//     final eitherEditFullName = await _profileRepository.updateProfile(
//         profile: profile!.copyWith(fullName: event.fullName));
//     eitherEditFullName.fold(
//       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
//       (success) => emit(state.copyWith(status: BlocStatus.success)),
//     );
//   }
// }
