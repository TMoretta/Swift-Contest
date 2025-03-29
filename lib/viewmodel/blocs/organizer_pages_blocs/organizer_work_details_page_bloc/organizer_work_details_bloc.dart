import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'organizer_work_details_event.dart';
part 'organizer_work_details_state.dart';

class OrganizerWorkDetailsBloc extends Bloc<OrganizerWorkDetailsEvent, OrganizerWorkDetailsState> {
  OrganizerWorkDetailsBloc() : super(OrganizerWorkDetailsInitial()) {
    on<OrganizerWorkDetailsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
