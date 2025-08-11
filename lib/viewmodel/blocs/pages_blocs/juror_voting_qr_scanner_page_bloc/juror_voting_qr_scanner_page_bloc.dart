import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/model/database/entities/voting_session.dart';
import 'package:swift_contest/model/database/repositories/juror_repository.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'juror_voting_qr_scanner_page_event.dart';

part 'juror_voting_qr_scanner_page_state.dart';

class JurorVotingQrScannerPageBloc extends Bloc<JurorVotingQrScannerPageEvent, JurorVotingQrScannerPageState> {
  final JurorRepository _jurorRepository;

  JurorVotingQrScannerPageBloc({required JurorRepository jurorRepository})
      : _jurorRepository = jurorRepository, super(JurorVotingQrScannerPageState(status: BlocStatus.initial)) {
    on<JurorVotingQrScannerPageAccessVotingAsSimpleJuror>(_accessVotingAsSimpleJuror);
  }

  FutureOr<void> _accessVotingAsSimpleJuror(
    JurorVotingQrScannerPageAccessVotingAsSimpleJuror event,
    Emitter<JurorVotingQrScannerPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final res = await _jurorRepository.accessVotingAsSimpleJuror(token: event.token);
    res.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => emit(state.copyWith(status: BlocStatus.success, votingSession: success)),
    );
  }
}
