import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/enums/voting_session_status.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_timer_countdown.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_widget.dart';
import 'package:swift_contest/view/widgets/obscured_loader.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/view/widgets/work_details_view.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_procedure_page_bloc/organizer_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerVotingProcedurePage extends StatefulWidget {
  final String votingSessionId;

  const OrganizerVotingProcedurePage({required this.votingSessionId, super.key});

  @override
  State<OrganizerVotingProcedurePage> createState() => _OrganizerVotingProcedurePageState();
}

class _OrganizerVotingProcedurePageState extends State<OrganizerVotingProcedurePage> {
  
  late Profile profile;
  late String votingSessionId;

  @override
  void initState() {
    super.initState();
    profile = context.read<AuthBloc>().state.profile!;
    votingSessionId = widget.votingSessionId;
    context.read<OrganizerVotingProcedurePageBloc>().add(
        OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure(
            votingSessionId: votingSessionId));
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerVotingProcedurePageBloc, OrganizerVotingProcedurePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if(state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.status.isSuccess &&
            state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus ==
                VotingSessionStatus.ended) {
          showSnackBar(context: context, text: 'Voting session ended successfully');
          context.pop(true);
        }
        if (state.status.isSuccess &&
            state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus ==
                VotingSessionStatus.cancelled) {
          showSnackBar(context: context, text: 'Voting session cancelled successfully');
          context.pop(true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(title: 'Voting'),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Builder(
                builder: (context) {
                  switch (state.status) {
                    case BlocStatus.initial:
                      return VoidWidget();
                    case BlocStatus.loading:
                      if (state.sourceEvent
                      is OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure) {
                        return VoidWidget();
                      } else {
                        continue successCase;
                      }
                    case BlocStatus.failure:
                      if (state.sourceEvent
                      is OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure) {
                        return RefreshIndicator.adaptive(
                          onRefresh: () async => context
                              .read<OrganizerVotingProcedurePageBloc>()
                              .add(OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure(
                              votingSessionId: votingSessionId)),
                          child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                        );
                      } else {
                        continue successCase;
                      }
                    successCase:
                    case BlocStatus.success:
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<OrganizerVotingProcedurePageBloc>()
                            .add(OrganizerVotingProcedurePageResubscribeToVotingSessionProcedure(
                            votingSessionId: votingSessionId)),
                        child: Builder(
                          builder: (context) {
                            final votingSessionProcedureBundle =
                            state.votingSessionProcedureBundle!;
                            final votingSessionBundle =
                                votingSessionProcedureBundle.votingSessionBundle;
                            final sessionStatus = votingSessionBundle.votingSession.sessionStatus;

                            switch (sessionStatus) {
                              case VotingSessionStatus.initialized:
                                return ListViewWithCentralWidget(
                                  centralWidget: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (votingSessionBundle
                                          .votingSession.areSimpleJurorsAllowed)
                                        Text(
                                          'Simple juror access token:\n${votingSessionProcedureBundle.votingSessionBundle.votingSession.token}',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      if (votingSessionBundle
                                          .votingSession.areSimpleJurorsAllowed)
                                        SizedBox(height: 16),
                                      FilledButton(
                                        onPressed: () {
                                          context.read<OrganizerVotingProcedurePageBloc>().add(
                                              OrganizerVotingProcedurePageStartVotingSessionProcedure(
                                                  votingSessionId: votingSessionProcedureBundle
                                                      .votingSessionBundle.votingSession.id));
                                        },
                                        child: Text('Start'),
                                      ),
                                    ],
                                  ),
                                );
                              case VotingSessionStatus.work:
                                final currentStepDeadline =
                                votingSessionBundle.votingSession.currentStepDeadline!;
                                final currentParticipantIndex =
                                votingSessionBundle.votingSession.currentParticipantIndex!;
                                final currentParticipant = votingSessionProcedureBundle
                                    .includedVotingSessionParticipationsBundles[
                                currentParticipantIndex]
                                    .participationBundle
                                    .participant;
                                final currentWork = votingSessionProcedureBundle
                                    .includedVotingSessionParticipationsBundles[
                                currentParticipantIndex]
                                    .participationBundle
                                    .work!;
                                return ListView(
                                  children: [
                                    SizedBox(height: 16),
                                    if (votingSessionBundle.votingSession.areSimpleJurorsAllowed)
                                      Text(
                                        'Simple juror access token:\n${votingSessionProcedureBundle.votingSessionBundle.votingSession.token}',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    if (votingSessionBundle.votingSession.areSimpleJurorsAllowed)
                                      Divider(height: 16),
                                    Center(
                                      child: CustomTimerCountdown(
                                        label: 'Jurors are voting',
                                        endTime: currentStepDeadline,
                                      ),
                                    ),
                                    Divider(height: 24),
                                    WorkDetailsView(
                                      work: currentWork,
                                      participant: currentParticipant,
                                    ),
                                    SizedBox(height: 72),
                                  ],
                                );
                              case VotingSessionStatus.intermission:
                                final currentStepDeadline =
                                votingSessionBundle.votingSession.currentStepDeadline!;
                                return ListViewWithCentralWidget(
                                  centralWidget: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (votingSessionBundle
                                          .votingSession.areSimpleJurorsAllowed)
                                        Text(
                                          'Simple juror access token:\n${votingSessionProcedureBundle.votingSessionBundle.votingSession.token}',
                                          style: Theme.of(context).textTheme.titleMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                      if (votingSessionBundle
                                          .votingSession.areSimpleJurorsAllowed)
                                        SizedBox(height: 16),
                                      CustomTimerCountdown(
                                          key: ValueKey(
                                              currentStepDeadline.millisecondsSinceEpoch),
                                          label: 'Intermission',
                                          endTime: currentStepDeadline),
                                    ],
                                  ),
                                );
                              case VotingSessionStatus.review:
                                final currentStepDeadline =
                                votingSessionBundle.votingSession.currentStepDeadline!;
                                return ListViewWithCentralWidget(
                                  centralWidget: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (votingSessionBundle
                                          .votingSession.areSimpleJurorsAllowed)
                                        Text(
                                          'Simple juror access token:\n${votingSessionProcedureBundle.votingSessionBundle.votingSession.token}',
                                          style: Theme.of(context).textTheme.titleMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                      if (votingSessionBundle
                                          .votingSession.areSimpleJurorsAllowed)
                                        SizedBox(height: 16),
                                      CustomTimerCountdown(
                                          key: ValueKey(
                                              currentStepDeadline.millisecondsSinceEpoch),
                                          label: 'Jurors are reviewing',
                                          endTime: currentStepDeadline),
                                    ],
                                  ),
                                );
                              case VotingSessionStatus.ended:
                              case VotingSessionStatus.cancelled:
                                return VoidWidget();
                            }
                          },
                        ),
                      );
                  }
                },
              ),
            ),
          ),
          floatingActionButton:
          Builder(
            builder: (context) {
              switch (state.status) {
                case BlocStatus.initial:
                  return VoidWidget();
                case (BlocStatus.loading || BlocStatus.failure):
                  if (state.sourceEvent
                  is OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure) {
                    return VoidWidget();
                  } else {
                    continue successCase;
                  }
                successCase:
                case BlocStatus.success:
                  final votingSessionBundle =
                      state.votingSessionProcedureBundle!.votingSessionBundle;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FilledButton(
                        onPressed: () {
                          context.read<OrganizerVotingProcedurePageBloc>().add(
                            OrganizerVotingProcedurePageCancelVotingSessionProcedure(
                              votingSessionId: votingSessionBundle.votingSession.id,
                            ),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                          WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.error),
                        ),
                        child: Text(
                          'Cancel procedure',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Theme.of(context).colorScheme.onError),
                        ),
                      ),
                      if (votingSessionBundle.votingSession.sessionStatus.isReview)
                        const SizedBox(width: 8),
                      if (votingSessionBundle.votingSession.sessionStatus.isReview)
                        FilledButton(
                          onPressed: () {
                            context.read<OrganizerVotingProcedurePageBloc>().add(
                              OrganizerVotingProcedurePageEndVotingSessionProcedure(
                                votingSessionId: votingSessionBundle.votingSession.id,
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                                Theme.of(context).colorScheme.green),
                          ),
                          child: Text(
                            'End procedure',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Theme.of(context).colorScheme.onGreen),
                          ),
                        ),
                    ],
                  );
              }
            },
          ),
        );
      },
    );
  }
}
