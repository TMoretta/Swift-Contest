// import 'dart:async';
//
// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:swift_contest/model/database/repositories/juror_repository.dart';
// import 'package:swift_contest/viewmodel/types/bloc_status.dart';
//
// part 'simple_juror_home_page_event.dart';
// part 'simple_juror_home_page_state.dart';
//
// class SimpleJurorHomePageBloc extends Bloc<SimpleJurorHomePageEvent, SimpleJurorHomePageState> {
//   final JurorRepository _jurorRepository;
//
//   SimpleJurorHomePageBloc({required JurorRepository jurorRepository})
//       : _jurorRepository = jurorRepository,
//         super(SimpleJurorHomePageState(status: BlocStatus.initial)) {
//     on<SimpleJurorHomePageAccessVoting>(_accessVoting);
//   }
//
//   FutureOr<void> _accessVoting(
//     SimpleJurorHomePageAccessVoting event,
//     Emitter<SimpleJurorHomePageState> emit,
//   ) async {
//     emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));
//   }
// }
