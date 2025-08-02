import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/entities/profile.dart';
import 'package:swift_contest/model/database/types/voting_session_status.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_procedure_page_bloc/organizer_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

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
  late Profile profile;
  late final String votingSessionId;

  @override
  void initState() {
    super.initState();
    profile = context.read<AuthBloc>().state.profile!;
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
          showSnackBar(context: context, text: 'Voting session ended successfully');
          context.router.pop();
          return;
        }
        if (state.status.isSuccess &&
            state.sourceEvent is OrganizerVotingProcedurePageCancelVotingSessionProcedure) {
          showSnackBar(context: context, text: 'Voting session cancelled successfully');
          context.router.pop();
          return;
        }
        if (state.votingSessionProcedureBundle?.votingSessionBundle.votingSession.sessionStatus
                .isEnded ??
            false) {
          showSnackBar(context: context, text: 'Voting session ended successfully');
          context.router.pop();
          return;
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
                        final votingSessionJuriesBundles =
                            state.votingSessionProcedureBundle!.votingSessionJuriesBundles;
                        return ListView(
                          children: [
                            // ...votingSessionJuriesBundles.map((votingSessionJuryBundle) {
                            //   return QrImageView(
                            //     data: votingSessionJuryBundle.votingSessionJury.token!,
                            //     backgroundColor: Theme.of(context).colorScheme.white,
                            //   );
                            // }),
                            Center(
                                child: Text(
                              'Jurors are voting',
                              style: Theme.of(context).textTheme.titleMedium,
                            )),
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
                  spacing: 8,
                  children: [
                    FilledButton(
                      onPressed: () {
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
                      onPressed: () {
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

          // Builder(
          //   builder: (context) {
          //     switch (state.status) {
          //       case BlocStatus.initial:
          //         return VoidWidget();
          //       case (BlocStatus.loading || BlocStatus.failure):
          //         if (!state.isInitialized) {
          //           return VoidWidget();
          //         } else {
          //           continue successCase;
          //         }
          //       successCase:
          //       case BlocStatus.success:
          //         final votingSessionBundle =
          //             state.votingSessionProcedureBundle!.votingSessionBundle;
          //         return Column(
          //           mainAxisSize: MainAxisSize.min,
          //           crossAxisAlignment: CrossAxisAlignment.end,
          //           children: [
          //             FilledButton(
          //               onPressed: () {
          //                 context.read<OrganizerVotingProcedurePageBloc>().add(
          //                       OrganizerVotingProcedurePageCancelVotingSessionProcedure(
          //                         votingSessionId: votingSessionBundle.votingSession.id!,
          //                       ),
          //                     );
          //               },
          //               style: ButtonStyle(
          //                 backgroundColor:
          //                     WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.error),
          //               ),
          //               child: Text(
          //                 'Cancel procedure',
          //                 textAlign: TextAlign.center,
          //                 style: Theme.of(context)
          //                     .textTheme
          //                     .bodyMedium
          //                     ?.copyWith(color: Theme.of(context).colorScheme.onError),
          //               ),
          //             ),
          //             if (votingSessionBundle.votingSession.sessionStatus.isReview)
          //               const SizedBox(width: 8),
          //             if (votingSessionBundle.votingSession.sessionStatus.isReview)
          //               FilledButton(
          //                 onPressed: () {
          //                   context.read<OrganizerVotingProcedurePageBloc>().add(
          //                         OrganizerVotingProcedurePageEndVotingSessionProcedure(
          //                           votingSessionId: votingSessionBundle.votingSession.id!,
          //                         ),
          //                       );
          //                 },
          //                 style: ButtonStyle(
          //                   backgroundColor:
          //                       WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.green),
          //                 ),
          //                 child: Text(
          //                   'End procedure',
          //                   textAlign: TextAlign.center,
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .bodyMedium
          //                       ?.copyWith(color: Theme.of(context).colorScheme.onGreen),
          //                 ),
          //               ),
          //           ],
          //         );
          //     }
          //   },
          // ),
        );
      },
    );
  }
}
