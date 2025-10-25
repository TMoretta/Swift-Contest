import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swift_contest/model/database/entities/voting_session.dart';
import 'package:swift_contest/model/database/repositories/juror_repository.dart';
import 'package:swift_contest/utils/permissions/permissions.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'juror_voting_qr_scanner_page_event.dart';
part 'juror_voting_qr_scanner_page_state.dart';

class JurorVotingQrScannerPageBloc
    extends Bloc<JurorVotingQrScannerPageEvent, JurorVotingQrScannerPageState> {
  final JurorRepository _jurorRepository;

  JurorVotingQrScannerPageBloc({required JurorRepository jurorRepository})
      : _jurorRepository = jurorRepository,
        super(const JurorVotingQrScannerPageState(status: BlocStatus.initial)) {
    on<JurorVotingQrScannerPageAccessVotingAsSimpleJuror>(_accessVotingAsSimpleJuror);
    on<JurorVotingQrScannerPageCheckCameraPermission>(_checkCameraPermissionStatus);
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

  FutureOr<void> _checkCameraPermissionStatus(
    JurorVotingQrScannerPageCheckCameraPermission event,
    Emitter<JurorVotingQrScannerPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final status = await requestCameraPermission();
    if (status.isPermanentlyDenied) {
      emit(state.copyWith(
          status: BlocStatus.failure,
          message: 'Permission has been permanently denied. Please enable it from app settings.'));
    }
    emit(state.copyWith(status: BlocStatus.success, cameraPermissionStatus: status));
  }
}
