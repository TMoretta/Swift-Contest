import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'data_transfer_event.dart';
part 'data_transfer_state.dart';

class DataTransferBloc extends Bloc<DataTransferEvent, DataTransferState> {
  DataTransferBloc() : super(DataTransferInitial()) {
    on<DataTransferSetData>(_setData);
    on<DataTransferClearData>(_clearData);
  }

  FutureOr<void> _setData(DataTransferSetData event, Emitter<DataTransferState> emit) {
    emit(DataTransferSuccess(data: event.data));
  }

  FutureOr<void> _clearData(
    DataTransferClearData event,
    Emitter<DataTransferState> emit,
  ) async {
    emit(DataTransferInitial());
  }
}
