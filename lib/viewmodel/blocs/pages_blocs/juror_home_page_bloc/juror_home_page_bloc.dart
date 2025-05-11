import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/model/data_models/juration.dart';
import 'package:swift_contest/model/enums/juror_status.dart';
import 'package:swift_contest/model/enums/member_role.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/invitation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juration_repository.dart';

part 'juror_home_page_event.dart';
part 'juror_home_page_state.dart';

class JurorHomePageBloc extends Bloc<JurorHomePageEvent, JurorHomePageState> {
  final JurationRepository _jurationRepository;
  final ContestRepository _contestRepository;
  final InvitationRepository _invitationRepository;

  JurorHomePageBloc({
    required JurationRepository jurationRepository,
    required ContestRepository contestRepository,
    required InvitationRepository invitationRepository,
  })  : _jurationRepository = jurationRepository,
        _contestRepository = contestRepository,
  _invitationRepository = invitationRepository,
        super(JurorHomePageState(status: BlocStatus.initial)) {
    on<JurorHomePageJoinContest>(_joinContest);
  }

  Future<void> _joinContest(
    JurorHomePageJoinContest event,
    Emitter<JurorHomePageState> emit,
  ) async {
    emit(JurorHomePageState(status: BlocStatus.loading));

    final eitherContest =
    await _contestRepository.getContestByToken(token: event.contestToken);
    late final Contest contest;
    eitherContest.fold(
          (failure) => emit(JurorHomePageState(
          status: BlocStatus.failure, message: failure.message)),
          (success) => contest = success,
    );
    if (eitherContest.isLeft()) return;

    late final List<Invitation> invitations;
    final eitherInvitations = await _invitationRepository
        .getInvitationsByContestIdAndMemberRole(contestId: contest.id, memberRole: MemberRole.juror);
    eitherInvitations.fold(
          (failure) => emit(JurorHomePageState(
          status: BlocStatus.failure, message: failure.message)),
          (success) => invitations = success,
    );
    if (eitherInvitations.isLeft()) return;

    if(invitations.isEmpty) {
      emit(JurorHomePageState(status: BlocStatus.failure,message: 'No invitation found with these credentials'));
    }

    for (var invitation in invitations) {
      if (invitation.token == event.jurorToken) {
        late final Juration juration;
        final eitherJuration =
        await _jurationRepository.createJuration(
            juration: Juration(
              id: invitation.id,
              createdAt: DateTime.now(),
              contestId: contest.id,
              jurorId: event.jurorId,
              jurorStatus: JurorStatus.joined,
            ));
        eitherJuration.fold(
              (failure) => emit(JurorHomePageState(
              status: BlocStatus.failure, message: failure.message)),
              (success) => juration = success,
        );
        if (eitherJuration.isLeft()) return;

        final eitherDeleteInvitation =
        await _invitationRepository.deleteInvitationById(id: invitation.id);
        eitherDeleteInvitation.fold(
                (failure) => emit(JurorHomePageState(
                status: BlocStatus.failure, message: failure.message)),
                (success) => null
        );
        if (eitherDeleteInvitation.isLeft()) return;

        emit(JurorHomePageState(status: BlocStatus.success,jurationJoin: juration));
        break;
      }
    }

    emit(JurorHomePageState(status: BlocStatus.failure,message: 'No invitation found with these credentials'));
  }
}
