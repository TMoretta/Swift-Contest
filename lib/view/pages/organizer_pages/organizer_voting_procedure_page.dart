import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:swift_contest/model/database/types/jury_type.dart';
import 'package:swift_contest/model/database/types/voting_session_status.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_procedure_page_bloc/organizer_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class OrganizerVotingProcedurePage extends StatefulWidget implements AutoRouteWrapper {
  final String votingSessionId;

  const OrganizerVotingProcedurePage({
    @PathParam('votingSessionId') required this.votingSessionId,
    super.key,
  });

  @override
  State<OrganizerVotingProcedurePage> createState() => _OrganizerVotingProcedurePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerVotingProcedurePageBloc>(
      create: (context) => OrganizerVotingProcedurePageBloc(
        organizerRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _OrganizerVotingProcedurePageState extends State<OrganizerVotingProcedurePage> {
  late final String votingSessionId;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    votingSessionId = widget.votingSessionId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context
        .read<OrganizerVotingProcedurePageBloc>()
        .add(OrganizerVotingProcedurePageFetch(votingSessionId: votingSessionId));
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
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.status.isSuccess &&
            state.sourceEvent is OrganizerVotingProcedurePageEndVotingSessionProcedure) {
          if (!isFinished) {
            isFinished = true;
            showSnackBar(context: context, text: 'Voting session ended successfully');
            context.router.pop();
          }
        }
        if (state.status.isSuccess &&
            state.sourceEvent is OrganizerVotingProcedurePageCancelVotingSessionProcedure) {
          if (!isFinished) {
            isFinished = true;
            showSnackBar(context: context, text: 'Voting session cancelled successfully');
            context.router.pop();
          }
        }
        if (state.votingSessionProcedureBundle != null &&
            !state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus
                .isLive) {
          if (!isFinished) {
            isFinished = true;
            showSnackBar(context: context, text: 'Voting session has terminated');
            context.router.pop();
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(title: 'Voting'),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Builder(
                builder: (context) {
                  if (!state.isInitialized) {
                    if (state.status.isFailure) {
                      return Center(
                        child: FilledButton(
                          onPressed: () async {
                            context.read<OrganizerVotingProcedurePageBloc>().add(
                                OrganizerVotingProcedurePageFetch(
                                    votingSessionId: votingSessionId));
                          },
                          child: Text('Retry'),
                        ),
                      );
                    }
                    return VoidWidget();
                  }
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context
                        .read<OrganizerVotingProcedurePageBloc>()
                        .add(OrganizerVotingProcedurePageFetch(votingSessionId: votingSessionId)),
                    child: Builder(
                      builder: (context) {
                        final List<({String name, String token})> tokensForSimpleJuries = state
                            .votingSessionProcedureBundle!.votingSessionJuriesBundles
                            .where((e) => e.votingSessionJury.juryType.isSimple)
                            .map((e) => (
                                  name: e.votingSessionJury.juryName,
                                  token: e.votingSessionJury.juryToken
                                ))
                            .toList(growable: false);
                        return ListView(
                          children: [
                            Center(child: Text('Voting Session is Live', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),),),
                            SizedBox(height: 16),
                            if(tokensForSimpleJuries.isNotEmpty)
                              ...tokensForSimpleJuries.map((e) {
                                final name = e.name;
                                final token = e.token;
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Theme.of(context).colorScheme.grey),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              name,
                                              style: Theme.of(context).textTheme.titleLarge,
                                            ),
                                            SizedBox(height: 4),
                                            QrImageView(
                                                data: token,
                                                size: 250,
                                                backgroundColor: Theme.of(context).colorScheme.white),
                                            SizedBox(height: 4),
                                            Text(
                                              token,
                                              style: Theme.of(context).textTheme.titleMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        );

                        // final votingSessionProcedureBundle =
                        //     state.votingSessionProcedureBundle!;
                        // final votingSessionBundle =
                        //     votingSessionProcedureBundle.votingSessionBundle;
                        // final sessionStatus = votingSessionBundle.votingSession.sessionStatus;
                        //
                        // switch (sessionStatus) {
                        //   case VotingSessionStatus.initialized:
                        //     return ListViewWithCentralWidget(
                        //       centralWidget: Column(
                        //         mainAxisSize: MainAxisSize.min,
                        //         children: [
                        //           if (votingSessionBundle.votingSession.areSimpleJurorsAllowed)
                        //             Text(
                        //               'Simple juror access token:\n${votingSessionProcedureBundle.contestToken}',
                        //               textAlign: TextAlign.center,
                        //               style: Theme.of(context).textTheme.titleMedium,
                        //             ),
                        //           if (votingSessionBundle.votingSession.areSimpleJurorsAllowed)
                        //             SizedBox(height: 16),
                        //           FilledButton(
                        //             onPressed: () {
                        //               context.read<OrganizerVotingProcedurePageBloc>().add(
                        //                   OrganizerVotingProcedurePageStartVotingSessionProcedure(
                        //                       votingSessionId: votingSessionProcedureBundle
                        //                           .votingSessionBundle.votingSession.id!));
                        //             },
                        //             child: Text('Start'),
                        //           ),
                        //         ],
                        //       ),
                        //     );
                        //   case VotingSessionStatus.work:
                        //     final currentStepDeadline =
                        //         votingSessionBundle.votingSession.currentStepDeadline!;
                        //     final currentParticipantIndex =
                        //         votingSessionBundle.votingSession.currentParticipantIndex!;
                        //     final currentVotingSessionParticipation =
                        //         votingSessionProcedureBundle
                        //             .votingSessionParticipations[currentParticipantIndex];
                        //     return ListView(
                        //       children: [
                        //         SizedBox(height: 16),
                        //         if (votingSessionBundle.votingSession.areSimpleJurorsAllowed)
                        //           Text(
                        //             'Simple juror access token:\n${votingSessionProcedureBundle.contestToken}',
                        //             textAlign: TextAlign.center,
                        //             style: Theme.of(context).textTheme.titleMedium,
                        //           ),
                        //         if (votingSessionBundle.votingSession.areSimpleJurorsAllowed)
                        //           Divider(height: 16),
                        //         Center(
                        //           child: CustomTimerCountdown(
                        //             label: 'Jurors are voting',
                        //             endTime: currentStepDeadline,
                        //             onEnd: () => context
                        //                 .read<OrganizerVotingProcedurePageBloc>()
                        //                 .add(
                        //                     const OrganizerVotingProcedurePageAdvanceSession()),
                        //           ),
                        //         ),
                        //         Divider(height: 24),
                        //         VotingProcedureWorkDetailsView(
                        //           workName: currentVotingSessionParticipation.workName,
                        //           workDescription:
                        //               currentVotingSessionParticipation.workDescription,
                        //           participantFullName:
                        //               currentVotingSessionParticipation.participantFullName,
                        //           workImagesUrls:
                        //               currentVotingSessionParticipation.workImagesUrls,
                        //         ),
                        //         SizedBox(height: 72),
                        //       ],
                        //     );
                        //   case VotingSessionStatus.intermission:
                        //     final currentStepDeadline =
                        //         votingSessionBundle.votingSession.currentStepDeadline!;
                        //     return ListViewWithCentralWidget(
                        //       centralWidget: Column(
                        //         mainAxisSize: MainAxisSize.min,
                        //         children: [
                        //           if (votingSessionBundle.votingSession.areSimpleJurorsAllowed)
                        //             Text(
                        //               'Simple juror access token:\n${votingSessionProcedureBundle.contestToken}',
                        //               style: Theme.of(context).textTheme.titleMedium,
                        //               textAlign: TextAlign.center,
                        //             ),
                        //           if (votingSessionBundle.votingSession.areSimpleJurorsAllowed)
                        //             SizedBox(height: 16),
                        //           CustomTimerCountdown(
                        //             key: ValueKey(currentStepDeadline.millisecondsSinceEpoch),
                        //             label: 'Intermission',
                        //             onEnd: () => context
                        //                 .read<OrganizerVotingProcedurePageBloc>()
                        //                 .add(
                        //                     const OrganizerVotingProcedurePageAdvanceSession()),
                        //             endTime: currentStepDeadline,
                        //           ),
                        //         ],
                        //       ),
                        //     );
                        //   case VotingSessionStatus.review:
                        //     final currentStepDeadline =
                        //         votingSessionBundle.votingSession.currentStepDeadline!;
                        //     return ListViewWithCentralWidget(
                        //       centralWidget: Column(
                        //         mainAxisSize: MainAxisSize.min,
                        //         children: [
                        //           if (votingSessionBundle.votingSession.areSimpleJurorsAllowed)
                        //             Text(
                        //               'Simple juror access token:\n${votingSessionProcedureBundle.contestToken}',
                        //               style: Theme.of(context).textTheme.titleMedium,
                        //               textAlign: TextAlign.center,
                        //             ),
                        //           if (votingSessionBundle.votingSession.areSimpleJurorsAllowed)
                        //             SizedBox(height: 16),
                        //           CustomTimerCountdown(
                        //             key: ValueKey(currentStepDeadline.millisecondsSinceEpoch),
                        //             label: 'Jurors are reviewing',
                        //             onEnd: () => context
                        //                 .read<OrganizerVotingProcedurePageBloc>()
                        //                 .add(
                        //                     const OrganizerVotingProcedurePageAdvanceSession()),
                        //             endTime: currentStepDeadline,
                        //           ),
                        //         ],
                        //       ),
                        //     );
                        //   case VotingSessionStatus.ended:
                        //   case VotingSessionStatus.cancelled:
                        //     return VoidWidget();
                        // }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          floatingActionButton: (state.isInitialized)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 8,
                  children: [
                    FilledButton(
                      onPressed: () async {
                        final bool res = await showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: Text('Cancel voting session'),
                                  content: Text(
                                      'Are you sure you want to cancel this voting session? This action cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        context.router.pop(false);
                                      },
                                      child: Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.router.pop(true);
                                      },
                                      child: Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            ) ??
                            false;
                        if (!context.mounted || !res) return;

                        context.read<OrganizerVotingProcedurePageBloc>().add(
                              OrganizerVotingProcedurePageCancelVotingSessionProcedure(
                                votingSessionId: state.votingSessionProcedureBundle!
                                    .votingSessionBundle.votingSession.id!,
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
                    FilledButton(
                      onPressed: () async {
                        final bool res = await showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: Text('End voting session'),
                                  content: Text(
                                      'Are you sure you want to end this voting session? Only already submitted votes will be counted.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        context.router.pop(false);
                                      },
                                      child: Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.router.pop(true);
                                      },
                                      child: Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            ) ??
                            false;
                        if (!context.mounted || !res) return;

                        context.read<OrganizerVotingProcedurePageBloc>().add(
                              OrganizerVotingProcedurePageEndVotingSessionProcedure(
                                votingSessionId: state.votingSessionProcedureBundle!
                                    .votingSessionBundle.votingSession.id!,
                              ),
                            );
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.green),
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
                )
              : VoidWidget(),
        );
      },
    );
  }
}
