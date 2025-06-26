import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/model/enums/voting_session_status.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/simple_juror_voting_procedure_page_bloc/simple_juror_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class SimpleJurorVotingProcedurePage extends StatefulWidget {
  final String simpleJurorId;
  final String votingSessionId;

  const SimpleJurorVotingProcedurePage({
    required this.simpleJurorId,
    required this.votingSessionId,
    super.key,
  });

  @override
  State<SimpleJurorVotingProcedurePage> createState() => _SimpleJurorVotingProcedurePageState();
}

class _SimpleJurorVotingProcedurePageState extends State<SimpleJurorVotingProcedurePage> {
  late String votingSessionId;
  late String simpleJurorId;
  Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap = {};

  @override
  void initState() {
    super.initState();
    votingSessionId = widget.votingSessionId;
    simpleJurorId = widget.simpleJurorId;
    context.read<SimpleJurorVotingProcedurePageBloc>().add(
        SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure(votingSessionId: votingSessionId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SimpleJurorVotingProcedurePageBloc, SimpleJurorVotingProcedurePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isSuccess &&
            state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus == VotingSessionStatus.ended) {
          showSnackBar(context: context, text: 'Voting session procedure is ended');
          context.pop();
        }
        if (state.status.isSuccess &&
            state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus ==
                VotingSessionStatus.cancelled) {
          showSnackBar(
              context: context,
              text: 'Voting session procedure has been cancelled by the organizer');
          context.pop();
        }
        if (state.status.isSuccess && state.sourceEvent is SimpleJurorVotingProcedurePageSubmitVotes) {
          showSnackBar(context: context, text: 'Votes submitted successfully');
          context.pop();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Voting'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<SimpleJurorVotingProcedurePageBloc,
                SimpleJurorVotingProcedurePageState>(
              builder: (context, state) {
                switch (state.status) {
                  case BlocStatus.initial:
                    return SizedBox.shrink();
                  case BlocStatus.loading:
                    return Loader();
                  case BlocStatus.failure:
                    if (state.sourceEvent
                        is SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<SimpleJurorVotingProcedurePageBloc>()
                            .add(SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure(
                                votingSessionId: votingSessionId)),
                        child: ListView(),
                      );
                    } else {
                      continue successCase;
                    }
                  successCase:
                  case BlocStatus.success:
                    final votingSessionProcedureBundle = state.votingSessionProcedureBundle!;
                    final votingSessionBundle = state.votingSessionProcedureBundle!.votingSessionBundle;
                    final votingSession = votingSessionBundle.votingSession;
                    final sessionStatus = votingSession.sessionStatus;
                    final votingFormFields = state.votingSessionProcedureBundle!.votingFormBundle.votingFormFields;

                    switch (sessionStatus) {
                      case VotingSessionStatus.initialized:
                        return Center(
                          child: Text(
                            'Await here the beginning of the voting session',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      case VotingSessionStatus.work:
                        final currentStepDeadline = votingSession.currentStepDeadline!;
                        final currentParticipantIndex = votingSession.currentParticipantIndex!;
                        final participant = votingSessionProcedureBundle
                            .votingSessionParticipationsBundles[currentParticipantIndex]
                            .participationBundle
                            .participant;
                        final work = votingSessionProcedureBundle
                            .votingSessionParticipationsBundles[currentParticipantIndex]
                            .participationBundle
                            .work;
                        final votingSessionParticipation = votingSessionProcedureBundle
                            .votingSessionParticipationsBundles[currentParticipantIndex]
                            .votingSessionParticipation;

                        return Column(
                          key: UniqueKey(),
                          children: [
                            TimerCountdown(endTime: currentStepDeadline),
                            Text('Current participant: ${participant.fullName}'),
                            Text('Current work: ${work?.name ?? 'Unavailable'}'),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                itemCount: votingFormFields.length,
                                itemBuilder: (context, index) {
                                  final field = votingFormFields[index];
                                  if (votesPerParticipantMap[votingSessionParticipation] == null) {
                                    votesPerParticipantMap.addAll({votingSessionParticipation: {}});
                                  }
                                  // votesPerParticipantMap[votingSessionParticipation]!.addAll({field: ''});
                                  return TextField(
                                    decoration: InputDecoration(label: Text(field.name)),
                                    onChanged: (value) {
                                      votesPerParticipantMap[votingSessionParticipation]!
                                          .addAll({field: double.parse(value)});
                                    },
                                  );
                                },
                              ),
                            ),
                            // Text('Deadline: ${currentStepDeadline.toIso8601String()}'),
                            // Text('Step: ${currentStep.name}'),
                            // Text('Participant: ${currentParticipant.fullName}'),
                          ],
                        );

                      case VotingSessionStatus.intermission:
                        final currentStepDeadline = votingSession.currentStepDeadline!;
                        return Center(
                          child: Column(
                            key: UniqueKey(),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Card(
                                elevation: 1,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Intermission',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TimerCountdown(
                                        endTime: currentStepDeadline,
                                        format: CountDownTimerFormat.minutesSeconds,
                                        timeTextStyle:
                                            TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      case VotingSessionStatus.review:
                      case VotingSessionStatus.ended:
                      case VotingSessionStatus.cancelled:
                        return SizedBox.shrink();
                    }
                }
              },
            ),
          ),
        ),
        floatingActionButton:
            BlocBuilder<SimpleJurorVotingProcedurePageBloc, SimpleJurorVotingProcedurePageState>(
          builder: (context, state) {
            if (state.votingSessionProcedureBundle == null) {
              return SizedBox.shrink();
            }
            final votingSessionBundle = state.votingSessionProcedureBundle!.votingSessionBundle;
            if (!votingSessionBundle.votingSession.sessionStatus.isReview) {
              return SizedBox.shrink();
            }
            return FilledButton(
              onPressed: (!state.status.isLoading)
                  ? () {
                      context
                          .read<SimpleJurorVotingProcedurePageBloc>()
                          .add(SimpleJurorVotingProcedurePageSubmitVotes(
                        simpleJurorId: simpleJurorId,
                        votingSession: votingSessionBundle.votingSession,
                        votesPerParticipantMap: votesPerParticipantMap,
                      ));
                    }
                  : null,
              child: Text('Submit'),
            );
          },
        ),
      ),
    );
  }
}
