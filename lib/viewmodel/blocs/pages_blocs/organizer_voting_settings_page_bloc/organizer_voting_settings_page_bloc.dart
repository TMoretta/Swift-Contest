import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';

part 'organizer_voting_settings_page_event.dart';
part 'organizer_voting_settings_page_state.dart';

class OrganizerVotingSettingsPageBloc
    extends Bloc<OrganizerVotingSettingsPageEvent, OrganizerVotingSettingsPageState> {
  OrganizerVotingSettingsPageBloc()
      : super(OrganizerVotingSettingsPageState(status: BlocStatus.initial)) {}
}
