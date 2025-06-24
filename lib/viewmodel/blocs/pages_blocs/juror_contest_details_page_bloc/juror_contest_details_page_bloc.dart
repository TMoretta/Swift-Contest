import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/repositories/role_repositories/juror_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'juror_contest_details_page_event.dart';

part 'juror_contest_details_page_state.dart';

class JurorContestDetailsPageBloc
    extends Bloc<JurorContestDetailsPageEvent, JurorContestDetailsPageState> {
  final JurorRepository _jurorRepository;

  JurorContestDetailsPageBloc({
    required JurorRepository jurorRepository,
  })  : _jurorRepository = jurorRepository,
        super(JurorContestDetailsPageState(status: BlocStatus.initial)) {
    on<JurorContestDetailsPageInit>(_init);
    on<JurorContestDetailsPageRefresh>(_refresh);
  }

  FutureOr<void> _init(
    JurorContestDetailsPageInit event,
    Emitter<JurorContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherContestDetails =
        await _jurorRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, contestDetailsBundle: success)),
    );
  }

  FutureOr<void> _refresh(
    JurorContestDetailsPageRefresh event,
    Emitter<JurorContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherContestDetails =
        await _jurorRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, contestDetailsBundle: success)),
    );
  }
}
