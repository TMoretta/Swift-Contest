import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/bundles/organizer_voting_session_bundle.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/model/enums/voting_session_status.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_procedure_page_bloc/organizer_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerVotingProcedurePage extends StatefulWidget {
  final OrganizerVotingSessionBundle votingSessionBundle;

  const OrganizerVotingProcedurePage({required this.votingSessionBundle, super.key});

  @override
  State<OrganizerVotingProcedurePage> createState() => _OrganizerVotingProcedurePageState();
}

class _OrganizerVotingProcedurePageState extends State<OrganizerVotingProcedurePage> {
  late User user;
  late OrganizerVotingSessionBundle votingSessionBundle;

  @override
  void initState() {
    super.initState();
    user = context.read<AuthBloc>().state.user!;
    votingSessionBundle = widget.votingSessionBundle;
    context.read<OrganizerVotingProcedurePageBloc>().add(
        OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure(
            votingSessionBundle: votingSessionBundle));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Voting'),
      body: BlocConsumer<OrganizerVotingProcedurePageBloc, OrganizerVotingProcedurePageState>(
        listener: (context, state) {
          if (state.status.isFailure && state.message != null) {
            showSnackBar(context: context, text: state.message!);
          }
          if (state.status.isSuccess &&
              state.votingSessionBundle!.votingSession.sessionStatus == VotingSessionStatus.ended) {
            showSnackBar(context: context, text: 'Voting session ended successfully');
            context.pop();
          }
          if (state.status.isSuccess &&
              state.votingSessionBundle!.votingSession.sessionStatus ==
                  VotingSessionStatus.cancelled) {
            showSnackBar(context: context, text: 'Voting session cancelled successfully');
            context.pop();
          }
        },
        builder: (context, state) {
          if (state.status.isFailure) {
            return FilledButton(
                onPressed: () {
                  context.read<OrganizerVotingProcedurePageBloc>().add(
                      OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure(
                          votingSessionBundle: votingSessionBundle));
                },
                child: Text('Reconnect'));
          }

          if (state.status.isSuccess) {
            final votingSessionBundle = state.votingSessionBundle!;
            final votingSession = votingSessionBundle.votingSession;
            // votingSessionProcedureId = state.votingSessionProcedure!.id;
            final sessionStatus = votingSession.sessionStatus;
            // final nextParticipant = state.participants![(currentParticipantIndex + 1) % state.participants!.length];
            // final nextWork = state.works![(currentParticipantIndex + 1) % state.works!.length];

            if (sessionStatus == VotingSessionStatus.initialized) {
              return Column(
                children: [
                  Text('Simple juror access token: ${votingSessionBundle.votingSession.token}'),
                  FilledButton(
                    onPressed: () {
                      context.read<OrganizerVotingProcedurePageBloc>().add(
                          OrganizerVotingProcedurePageStartVotingSessionProcedure(
                              votingSessionId: votingSessionBundle.votingSession.id));
                    },
                    child: Text('Start'),
                  ),
                ],
              );
            }

            if (sessionStatus == VotingSessionStatus.work) {
              final currentStepDeadline = votingSession.currentStepDeadline!;
              final currentParticipantIndex = votingSession.currentParticipantIndex!;
              final currentParticipant = votingSessionBundle
                  .votingSessionParticipationsBundles[currentParticipantIndex]
                  .participationBundle
                  .participant;
              final currentWork = votingSessionBundle
                  .votingSessionParticipationsBundles[currentParticipantIndex]
                  .participationBundle
                  .work!;
              return Column(
                key: UniqueKey(),
                children: [
                  Text('Simple juror access token: ${votingSessionBundle.votingSession.token}'),
                  Text('Jurors are voting'),
                  TimerCountdown(endTime: currentStepDeadline),
                  Text('Current participant: ${currentParticipant.fullName}'),
                  Text('Current work: ${currentWork.name}'),
                  // Text('Deadline: ${currentStepDeadline.toIso8601String()}'),
                  // Text('Step: ${currentStep.name}'),
                  // Text('Participant: ${currentParticipant.fullName}'),
                ],
              );
            }

            if (sessionStatus == VotingSessionStatus.intermission) {
              final currentStepDeadline = votingSession.currentStepDeadline!;
              return Column(
                key: UniqueKey(),
                children: [
                  Text('Simple juror access token: ${votingSessionBundle.votingSession.token}'),
                  Text('Intermission'),
                  TimerCountdown(endTime: currentStepDeadline),
                ],
              );
            }

            if (sessionStatus == VotingSessionStatus.review) {
              final currentStepDeadline = votingSession.currentStepDeadline!;
              return Column(
                key: UniqueKey(),
                children: [
                  Text('Simple juror access token: ${votingSessionBundle.votingSession.token}'),
                  Text('Jurors are reviewing'),
                  TimerCountdown(endTime: currentStepDeadline),
                ],
              );
            }
          }
          return Loader();
        },
      ),
      floatingActionButton:
          BlocConsumer<OrganizerVotingProcedurePageBloc, OrganizerVotingProcedurePageState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            showSnackBar(context: context, text: state.message!);
          }
        },
        builder: (context, state) {
          return FloatingActionButton(
            onPressed: (state.status.isSuccess || state.status.isFailure)
                ? () {
                    context.read<OrganizerVotingProcedurePageBloc>().add(
                        OrganizerVotingProcedurePageCancelVotingSessionProcedure(
                            votingSessionId: votingSessionBundle.votingSession.id));
                  }
                : () {},
            child: Text('Cancel procedure'),
          );
        },
      ),
    );
  }
}
