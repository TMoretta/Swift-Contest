import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/viewmodel/utils/bloc_status.dart';

part 'organizer_voting_settings_page_event.dart';

part 'organizer_voting_settings_page_state.dart';

class OrganizerVotingSettingsPageBloc
    extends Bloc<OrganizerVotingSettingsPageEvent, OrganizerVotingSettingsPageState> {
  OrganizerVotingSettingsPageBloc()
      : super(OrganizerVotingSettingsPageState(status: BlocStatus.initial)) {
    on<OrganizerVotingSettingsPageInit>(_init);
  }

  Future<void> _init(
    OrganizerVotingSettingsPageInit event,
    Emitter<OrganizerVotingSettingsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
  }
}
