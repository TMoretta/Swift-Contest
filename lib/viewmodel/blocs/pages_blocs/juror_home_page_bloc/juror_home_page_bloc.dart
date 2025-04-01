import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/juration/juration.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/juration_repository.dart';

part 'juror_home_page_event.dart';
part 'juror_home_page_state.dart';

class JurorHomePageBloc extends Bloc<JurorHomePageEvent, JurorHomePageState> {
  final JurationRepository _jurationRepository;

  JurorHomePageBloc({
    required JurationRepository jurationRepository,
  })  : _jurationRepository = jurationRepository,
        super(JurorHomePageState(status: BlocStatus.initial)) {
    on<JurorHomePageJoinContest>(_joinContest);
  }

  FutureOr<void> _joinContest(
    JurorHomePageJoinContest event,
    Emitter<JurorHomePageState> emit,
  ) async {
    emit(JurorHomePageState(status: BlocStatus.loading));
    final res = await _jurationRepository.joinContestAsJuror(
      jurorId: event.jurorId,
      contestToken: event.contestToken,
      jurorToken: event.jurorToken,
    );
    res.fold(
          (failure) => emit(JurorHomePageState(status: BlocStatus.failure, message: failure.message)),
          (success) => emit(JurorHomePageState(status: BlocStatus.success, jurationJoin: success)),
    );
  }
}
