import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/repositories/role_repositories/juror_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'juror_home_page_event.dart';
part 'juror_home_page_state.dart';

class JurorHomePageBloc extends Bloc<JurorHomePageEvent, JurorHomePageState> {
  final JurorRepository _jurorRepository;

  JurorHomePageBloc({
    required JurorRepository jurorRepository,
  })  :
        _jurorRepository = jurorRepository,
        super(JurorHomePageState(status: BlocStatus.initial)) {
    on<JurorHomePageInit>(_init);
    on<JurorHomePageRefresh>(_refresh);
    on<JurorHomePageJoinContest>(_joinContest);
  }

  FutureOr<void> _init(
    JurorHomePageInit event,
    Emitter<JurorHomePageState> emit,
  ) async {
    emit(JurorHomePageState(status: BlocStatus.loading, sourceEvent: event));

    final eitherContests = await _jurorRepository.getJoinedContests(jurorId: event.jurorId);
    eitherContests.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
          (success) => emit(state.copyWith(status: BlocStatus.success,joinedContestsBundles: success)),
    );
  }

  FutureOr<void> _refresh(JurorHomePageRefresh event, Emitter<JurorHomePageState> emit,) async{
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherContests = await _jurorRepository.getJoinedContests(jurorId: event.jurorId);
    eitherContests.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
          (success) => emit(state.copyWith(status: BlocStatus.success,joinedContestsBundles: success)),
    );
  }

  //* Join contest
  FutureOr<void> _joinContest(
    JurorHomePageJoinContest event,
    Emitter<JurorHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherJoinContest = await _jurorRepository.joinContest(
        jurorId: event.jurorId, token: event.token);
    eitherJoinContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }


}
