import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/db/entities/voting_form_field.dart';
import 'package:swift_contest/model/db/entities/voting_session_participation.dart';
import 'package:swift_contest/model/db/types/voting_session_status.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/view/widgets/voting_procedure_form_and_work_view.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_voting_procedure_page_bloc/juror_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class JurorVotingProcedurePage extends StatefulWidget implements AutoRouteWrapper {
  final String votingSessionId;

  const JurorVotingProcedurePage({
    @PathParam('votingSessionId') required this.votingSessionId,
    super.key,
  });

  @override
  State<JurorVotingProcedurePage> createState() => _JurorVotingProcedurePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<JurorVotingProcedurePageBloc>(
      create: (context) => JurorVotingProcedurePageBloc(
        jurorRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _JurorVotingProcedurePageState extends State<JurorVotingProcedurePage> {
  late String profileId;
  late final String votingSessionId;
  final reviewFormKey = GlobalKey<FormState>();
  final List<VotingProcedureFormAndWorkView> votingFormAndWorkViews = [];
  final Map<VotingSessionParticipation, Map<VotingFormField, TextEditingController>> votesMap = {};
  bool isPageInitialized = false;

  @override
  void initState() {
    super.initState();
    votingSessionId = widget.votingSessionId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileId = context.read<AuthBloc>().state.profile!.id!;
    context
        .read<JurorVotingProcedurePageBloc>()
        .add(JurorVotingProcedurePageFetch(votingSessionId: votingSessionId));
  }

  @override
  void dispose() {
    context.hideLoader();
    votesMap.forEach((key, value) {
      value.forEach((key, value) {
        value.dispose();
      });
    });
    reviewFormKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JurorVotingProcedurePageBloc, JurorVotingProcedurePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus
            .isEnded) {
          showSnackBar(context: context, text: 'Voting session procedure is ended');
          context.router.pop(true);
        }
        if (state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus
            .isCancelled) {
          showSnackBar(context: context, text: 'Voting session procedure has been cancelled');
          context.router.pop(true);
        }
        if (state.status.isSuccess && state.sourceEvent is JurorVotingProcedurePageSubmitVotes) {
          showSnackBar(context: context, text: 'Votes submitted successfully');
          context.router.pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Voting',
            onRefresh: () => context.read<JurorVotingProcedurePageBloc>().add(
                  JurorVotingProcedurePageFetch(votingSessionId: votingSessionId),
                ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Builder(
                builder: (context) {
                  switch (state.status) {
                    case BlocStatus.initial:
                      return VoidWidget();
                    case BlocStatus.loading:
                      if (!state.isInitialized) {
                        return VoidWidget();
                      } else {
                        continue successCase;
                      }
                    case BlocStatus.failure:
                      if (!state.isInitialized) {
                        return RefreshIndicator.adaptive(
                          onRefresh: () async => context
                              .read<JurorVotingProcedurePageBloc>()
                              .add(JurorVotingProcedurePageFetch(votingSessionId: votingSessionId)),
                          child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                        );
                      } else {
                        continue successCase;
                      }
                    successCase:
                    case BlocStatus.success:
                      final votingSessionProcedureBundle = state.votingSessionProcedureBundle!;
                      final votingSessionBundle = votingSessionProcedureBundle.votingSessionBundle;
                      final votingSession = votingSessionBundle.votingSession;
                      final ownVotingSessionJuration = state.ownVotingSessionJuration!;
                      final ownVotingSessionJuryBundle =
                          votingSessionProcedureBundle.votingSessionJuriesBundles.firstWhere(
                        (juryBundle) =>
                            juryBundle.votingSessionJury.id ==
                            ownVotingSessionJuration.votingSessionJuryId,
                      );
                      final votingSessionParticipations =
                          votingSessionProcedureBundle.votingSessionParticipations;
                      final votingFormFields =
                          ownVotingSessionJuryBundle.votingFormBundle.votingFormFields;

                      if (!isPageInitialized) {
                        for (var votingSessionParticipation in votingSessionParticipations) {
                          final Map<VotingFormField, TextEditingController> fieldsControllers = {};
                          for (var votingFormField in votingFormFields) {
                            fieldsControllers.addAll({votingFormField: TextEditingController()});
                          }
                          votesMap.addAll({votingSessionParticipation: fieldsControllers});
                          final isExcludedFromParticipant =
                              votingSessionProcedureBundle.votingSessionExclusions.any((e) =>
                                  e.votingSessionJurationId == ownVotingSessionJuration.id &&
                                  e.votingSessionParticipationId == votingSessionParticipation.id);
                          votingFormAndWorkViews.add(VotingProcedureFormAndWorkView(
                              isExcludedFromParticipant: isExcludedFromParticipant,
                              votingSessionParticipation: votingSessionParticipation,
                              votingFormFields: votingFormFields,
                              votesMap: votesMap));
                        }
                        isPageInitialized = true;
                      }

                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<JurorVotingProcedurePageBloc>()
                            .add(JurorVotingProcedurePageFetch(votingSessionId: votingSessionId)),
                        child: ListView.builder(
                          itemCount: votingFormAndWorkViews.length,
                          itemBuilder: (context, index) {
                            return votingFormAndWorkViews[index];
                          },
                        ),
                      );

                    // final votingSessionProcedureBundle = state.votingSessionProcedureBundle!;
                    // final votingSessionBundle = votingSessionProcedureBundle.votingSessionBundle;
                    // final votingSession = votingSessionBundle.votingSession;
                    // final sessionStatus = votingSessionBundle.votingSession.sessionStatus;
                    // final ownVotingSessionJuration = state.ownVotingSessionJuration!;
                    // final ownVotingSessionJuryBundle =
                    //     votingSessionProcedureBundle.votingSessionJuriesBundles.firstWhere(
                    //   (juryBundle) =>
                    //       juryBundle.votingSessionJury.id ==
                    //       ownVotingSessionJuration.votingSessionJuryId,
                    // );
                    // final votingFormFields =
                    //     ownVotingSessionJuryBundle.votingFormBundle.votingFormFields;
                    //
                    // if (!isPageInitialized) {
                    //   final votingSessionParticipations =
                    //       votingSessionProcedureBundle.votingSessionParticipations;
                    //   for (var votingSessionParticipation in votingSessionParticipations) {
                    //     final Map<VotingFormField, TextEditingController> fieldsControllers = {};
                    //     for (var votingFormField in votingFormFields) {
                    //       fieldsControllers.addAll({votingFormField: TextEditingController()});
                    //     }
                    //     votesMap.addAll({votingSessionParticipation: fieldsControllers});
                    //     final isExcludedFromParticipant =
                    //         votingSessionProcedureBundle.votingSessionExclusions.any((e) =>
                    //             e.votingSessionJurationId == ownVotingSessionJuration.id &&
                    //             e.votingSessionParticipationId == votingSessionParticipation.id);
                    //     votingFormAndWorkViews.add(VotingProcedureFormAndWorkView(
                    //       isExcludedFromParticipant: isExcludedFromParticipant,
                    //       votingSessionParticipation: votingSessionParticipation,
                    //       votingFormFields: votingFormFields,
                    //       votesMap: votesMap,
                    //     ));
                    //   }
                    //   isPageInitialized = true;
                    // }
                    //
                    // return RefreshIndicator.adaptive(
                    //   onRefresh: () async => context
                    //       .read<JurorVotingProcedurePageBloc>()
                    //       .add(JurorVotingProcedurePageFetch(votingSessionId: votingSessionId)),
                    //   child: Builder(
                    //     builder: (context) {
                    //       switch (sessionStatus) {
                    //         case VotingSessionStatus.initialized:
                    //           return ListViewWithCentralLabel(
                    //             label: 'Await here the beginning of the voting session',
                    //           );
                    //         case VotingSessionStatus.work:
                    //           final currentStepDeadline = votingSession.currentStepDeadline!;
                    //           final currentParticipantIndex =
                    //               votingSession.currentParticipantIndex!;
                    //
                    //           return ListView(
                    //             children: [
                    //               SizedBox(height: 16),
                    //               Center(
                    //                 child: CustomTimerCountdown(
                    //                   label: 'Voting phase',
                    //                   endTime: currentStepDeadline,
                    //                 ),
                    //               ),
                    //               Divider(height: 24),
                    //               votingFormAndWorkViews[currentParticipantIndex],
                    //               SizedBox(height: 72),
                    //             ],
                    //           );
                    //         case VotingSessionStatus.intermission:
                    //           final currentStepDeadline = votingSession.currentStepDeadline!;
                    //           return ListViewWithCentralWidget(
                    //             centralWidget: CustomTimerCountdown(
                    //               label: 'Intermission',
                    //               endTime: currentStepDeadline,
                    //             ),
                    //           );
                    //         case VotingSessionStatus.review:
                    //           final currentStepDeadline = votingSession.currentStepDeadline!;
                    //
                    //           return ListView(
                    //             children: [
                    //               SizedBox(height: 16),
                    //               Center(
                    //                 child: CustomTimerCountdown(
                    //                   label: 'Review',
                    //                   endTime: currentStepDeadline,
                    //                 ),
                    //               ),
                    //               Divider(height: 24),
                    //               Form(
                    //                 key: reviewFormKey,
                    //                 child: Column(
                    //                   mainAxisSize: MainAxisSize.min,
                    //                   children: [
                    //                     ...votingFormAndWorkViews,
                    //                     SizedBox(height: 72),
                    //                   ],
                    //                 ),
                    //               ),
                    //             ],
                    //           );
                    //         case VotingSessionStatus.ended:
                    //         case VotingSessionStatus.cancelled:
                    //           return VoidWidget();
                    //       }
                    //     },
                    //   ),
                    // );
                  }
                },
              ),
            ),
          ),
          floatingActionButton: (state.isInitialized)
              ? FilledButton(
                  onPressed: () {
                    if (reviewFormKey.currentState?.validate() ?? false) {
                      // MODIFICATO: La mappa ora contiene String come valore.
                      final Map<VotingSessionParticipation, Map<VotingFormField, String>>
                          votesPerParticipantMap = {};
                      for (var entry in votesMap.entries) {
                        final votingSessionParticipation = entry.key;
                        final votingFormFieldAndController = entry.value;
                        final Map<VotingFormField, String> votes = {};
                        for (var votingFormFieldAndControllerEntry
                            in votingFormFieldAndController.entries) {
                          final votingFormField = votingFormFieldAndControllerEntry.key;
                          final controller = votingFormFieldAndControllerEntry.value;
                          if (controller.text.isNotEmpty) {
                            // MODIFICATO: Non si fa più il parse a double, si prende il testo.
                            votes.addAll({votingFormField: controller.text});
                          } else {
                            // Se anche un solo campo non è compilato per un partecipante,
                            // non includiamo i voti per quel partecipante (a meno che non sia escluso).
                            final isExcluded = votingFormAndWorkViews
                                .firstWhere((v) =>
                                    v.votingSessionParticipation == votingSessionParticipation)
                                .isExcludedFromParticipant;
                            if (!isExcluded) {
                              votes.clear(); // Pulisce i voti parziali per questo partecipante
                              break;
                            }
                          }
                        }
                        if (votes.isNotEmpty) {
                          votesPerParticipantMap.addAll({votingSessionParticipation: votes});
                        }
                      }

                      // Invia il nuovo evento semplificato.
                      context
                          .read<JurorVotingProcedurePageBloc>()
                          .add(JurorVotingProcedurePageSubmitVotes(
                            votesPerParticipantMap: votesPerParticipantMap,
                          ));
                    } else {
                      showSnackBar(context: context, text: 'Fill all the fields');
                    }
                  },
                  child: Text('Submit'),
                )
              : null,

          // Builder(
          //   builder: (
          //     context,
          //   ) {
          //     if(state.isInitialized && (state.votingSessionProcedureBundle?.votingSessionBundle.votingSession.sessionStatus.isReview ?? false)) {
          //       return FilledButton(onPressed: (){}, child: Text('Submit'),);
          //     }
          //
          //     // switch (state.status) {
          //     //   case BlocStatus.initial:
          //     //     return VoidWidget();
          //     //   case (BlocStatus.loading || BlocStatus.failure):
          //     //     if (!state.isInitialized) {
          //     //       return VoidWidget();
          //     //     } else {
          //     //       continue successCase;
          //     //     }
          //     //   successCase:
          //     //   case BlocStatus.success:
          //     //     final votingSessionBundle =
          //     //         state.votingSessionProcedureBundle!.votingSessionBundle;
          //     //     final votingSession = votingSessionBundle.votingSession;
          //     //     if (!votingSession.sessionStatus.isReview) {
          //     //       return VoidWidget();
          //     //     }
          //     //     return FilledButton(
          //     //       onPressed: () {
          //     //         if (reviewFormKey.currentState?.validate() ?? false) {
          //     //           final Map<VotingSessionParticipation, Map<VotingFormField, double>>
          //     //               votesPerParticipantMap = {};
          //     //           for (var entry in votesMap.entries) {
          //     //             final votingSessionParticipation = entry.key;
          //     //             final votingFormFieldAndController = entry.value;
          //     //             final Map<VotingFormField, double> votes = {};
          //     //             for (var votingFormFieldAndControllerEntry
          //     //                 in votingFormFieldAndController.entries) {
          //     //               final votingFormField = votingFormFieldAndControllerEntry.key;
          //     //               final controller = votingFormFieldAndControllerEntry.value;
          //     //               if (controller.text.isNotEmpty) {
          //     //                 votes.addAll({votingFormField: double.parse(controller.text)});
          //     //               } else {
          //     //                 break;
          //     //               }
          //     //             }
          //     //             if (votes.isNotEmpty) {
          //     //               votesPerParticipantMap.addAll({votingSessionParticipation: votes});
          //     //             }
          //     //           }
          //     //           context
          //     //               .read<JurorVotingProcedurePageBloc>()
          //     //               .add(JurorVotingProcedurePageSubmitVotes(
          //     //                 votingSession: votingSession,
          //     //                 geoResPlace: votingSessionBundle.geoResPlace,
          //     //                 votesPerParticipantMap: votesPerParticipantMap,
          //     //               ));
          //     //         } else {
          //     //           showSnackBar(context: context, text: 'Fill all the fields');
          //     //         }
          //     //       },
          //     //       child: Text('Submit'),
          //     //     );
          //     // }
          //   },
          // ),
        );
      },
    );
  }
}
