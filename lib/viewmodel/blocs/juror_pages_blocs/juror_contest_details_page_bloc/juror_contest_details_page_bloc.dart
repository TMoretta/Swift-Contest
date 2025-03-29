import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/contest/contest.dart';
import 'package:swift_contest/model/data_models/participation/participation.dart';
import 'package:swift_contest/model/data_models/profile/profile.dart';
import 'package:swift_contest/model/data_models/work/work.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/utils/bloc_status.dart';

part 'juror_contest_details_page_event.dart';

part 'juror_contest_details_page_state.dart';

class JurorContestDetailsPageBloc
    extends Bloc<JurorContestDetailsPageEvent, JurorContestDetailsPageState> {
  final ContestRepository _contestRepository;
  final ProfileRepository _profileRepository;

  JurorContestDetailsPageBloc(
      {required ContestRepository contestRepository, required ProfileRepository profileRepository})
      : _contestRepository = contestRepository,
        _profileRepository = profileRepository,
        super(JurorContestDetailsPageState(status: BlocStatus.initial)) {
    on<JurorContestDetailsPageGetExtendedContest>(_getExtendedContest);
  }

  Future<void> _getExtendedContest(
    JurorContestDetailsPageGetExtendedContest event,
    Emitter<JurorContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final Contest contest;
    late final Profile organizer;

    //* Ottengo il contest
    final resContest = await _contestRepository.getContestById(id: event.contestId);
    resContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contest = success,
    );
    if (resContest.isLeft()) return;

    //* Ottengo l'organizer
    final resOrganizer = await _profileRepository.getProfileById(id: contest.organizerId);
    resOrganizer.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => organizer = success,
    );
    if (resOrganizer.isLeft()) return;

    emit(state.copyWith(status: BlocStatus.success, contest: contest, organizer: organizer));
  }
}
