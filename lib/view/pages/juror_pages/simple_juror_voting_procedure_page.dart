// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:swift_contest/model/data_models/voting_form_field.dart';
// import 'package:swift_contest/model/data_models/voting_session_participation.dart';
// import 'package:swift_contest/model/db/types/voting_session_status.dart';
// import 'package:swift_contest/utils/labels/labels.dart';
// import 'package:swift_contest/utils/router/app_router.gr.dart';
// import 'package:swift_contest/view/widgets/custom_app_bar.dart';
// import 'package:swift_contest/view/widgets/custom_timer_countdown.dart';
// import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
// import 'package:swift_contest/view/widgets/list_view_with_central_widget.dart';
// import 'package:swift_contest/view/widgets/overlay_loader.dart';
// import 'package:swift_contest/view/widgets/show_snack_bar.dart';
// import 'package:swift_contest/view/widgets/void_widget.dart';
// import 'package:swift_contest/view/widgets/voting_procedure_form_and_work_view.dart';
// import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/simple_juror_voting_procedure_page_bloc/simple_juror_voting_procedure_page_bloc.dart';
// import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
//
// @RoutePage()
// class SimpleJurorVotingProcedurePage extends StatefulWidget implements AutoRouteWrapper {
//   final String simpleJurorId;
//   final String votingSessionId;
//
//   const SimpleJurorVotingProcedurePage({
//     @PathParam('simpleJurorId') required this.simpleJurorId,
//     @PathParam('votingSessionId') required this.votingSessionId,
//     super.key,
//   });
//
//   @override
//   State<SimpleJurorVotingProcedurePage> createState() => _SimpleJurorVotingProcedurePageState();
//
//   @override
//   Widget wrappedRoute(BuildContext context) {
//     return BlocProvider<SimpleJurorVotingProcedurePageBloc>(
//       create: (context) => SimpleJurorVotingProcedurePageBloc(
//         jurorRepository: context.read(),
//       ),
//       child: this,
//     );
//   }
// }
//
// class _SimpleJurorVotingProcedurePageState extends State<SimpleJurorVotingProcedurePage> {
//   late String? profileId;
//   late final String votingSessionId;
//   late final String simpleJurorId;
//   final reviewFormKey = GlobalKey<FormState>();
//   final List<VotingProcedureFormAndWorkView> votingFormAndWorkViews = [];
//   final Map<VotingSessionParticipation, Map<VotingFormField, TextEditingController>> votesMap = {};
//   bool isPageInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     votingSessionId = widget.votingSessionId;
//     simpleJurorId = widget.simpleJurorId;
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     profileId = context.read<AuthBloc>().state.profile?.id;
//     context
//         .read<SimpleJurorVotingProcedurePageBloc>()
//         .add(SimpleJurorVotingProcedurePageFetch(votingSessionId: votingSessionId));
//   }
//
//   @override
//   void dispose() {
//     context.hideLoader();
//     votesMap.forEach((key, value) {
//       value.forEach((key, value) {
//         value.dispose();
//       });
//     });
//     reviewFormKey.currentState?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<SimpleJurorVotingProcedurePageBloc, SimpleJurorVotingProcedurePageState>(
//       listener: (context, state) {
//         if (state.message != null) {
//           showSnackBar(context: context, text: state.message!);
//         }
//         if (state.status.isLoading) {
//           context.showLoader();
//         } else {
//           context.hideLoader();
//         }
//         if (state.status.isSuccess &&
//             state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus ==
//                 VotingSessionStatus.ended) {
//           showSnackBar(context: context, text: 'Voting session procedure is ended');
//           if(context.router.canPop()) {
//             context.router.pop(true);
//           } else {
//             context.router.replaceAll([RootRoute()]);
//           }
//         }
//         if (state.status.isSuccess &&
//             state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus ==
//                 VotingSessionStatus.cancelled) {
//           showSnackBar(context: context, text: 'Voting session procedure has been cancelled by the organizer');
//           if(context.router.canPop()) {
//             context.router.pop();
//           } else {
//             context.router.replaceAll([RootRoute()]);
//           }
//         }
//         if (state.status.isSuccess &&
//             state.sourceEvent is SimpleJurorVotingProcedurePageSubmitVotes) {
//           showSnackBar(context: context, text: 'Votes submitted successfully');
//           if(context.router.canPop()) {
//             context.router.pop();
//           } else {
//             context.router.replaceAll([RootRoute()]);
//           }
//         }
//       },
//       builder: (context, state) {
//         return Scaffold(
//           appBar: CustomAppBar(title: 'Voting', onRefresh: () => context.read<SimpleJurorVotingProcedurePageBloc>().add(SimpleJurorVotingProcedurePageFetch(votingSessionId: votingSessionId)),),
//           body: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Builder(
//                 builder: (context) {
//                   switch (state.status) {
//                     case BlocStatus.initial:
//                       return VoidWidget();
//                     case BlocStatus.loading:
//                       if (!state.isInitialized) {
//                         return VoidWidget();
//                       } else {
//                         continue successCase;
//                       }
//                     case BlocStatus.failure:
//                       if (!state.isInitialized) {
//                         return RefreshIndicator.adaptive(
//                           onRefresh: () async => context
//                               .read<SimpleJurorVotingProcedurePageBloc>()
//                               .add(SimpleJurorVotingProcedurePageFetch(
//                                   votingSessionId: votingSessionId)),
//                           child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
//                         );
//                       } else {
//                         continue successCase;
//                       }
//                     successCase:
//                     case BlocStatus.success:
//                       final votingSessionProcedureBundle = state.votingSessionProcedureBundle!;
//                       final votingSessionBundle =
//                           state.votingSessionProcedureBundle!.votingSessionBundle;
//                       final votingSession = votingSessionBundle.votingSession;
//                       final sessionStatus = votingSession.sessionStatus;
//                       final votingFormFields =
//                           state.votingSessionProcedureBundle!.votingFormBundle.votingFormFields;
//
//                       if (!isPageInitialized) {
//                         final votingSessionParticipationsBundles =
//                             votingSessionProcedureBundle.includedVotingSessionParticipationsBundles;
//                         for (var votingSessionParticipationBundle
//                             in votingSessionParticipationsBundles) {
//                           final Map<VotingFormField, TextEditingController> fieldsControllers = {};
//                           for (var votingFormField in votingFormFields) {
//                             fieldsControllers.addAll({votingFormField: TextEditingController()});
//                           }
//                           final votingSessionParticipation =
//                               votingSessionParticipationBundle.votingSessionParticipation;
//                           votesMap.addAll({votingSessionParticipation: fieldsControllers});
//                           votingFormAndWorkViews.add(VotingProcedureFormAndWorkView(
//                             isExcludedFromParticipant: false,
//                             votingSessionParticipationBundle: votingSessionParticipationBundle,
//                             votingFormFields: votingFormFields,
//                             votesMap: votesMap,
//                           ));
//                         }
//                         isPageInitialized = true;
//                       }
//
//                       return RefreshIndicator.adaptive(
//                         onRefresh: () async => context
//                             .read<SimpleJurorVotingProcedurePageBloc>()
//                             .add(SimpleJurorVotingProcedurePageFetch(
//                                 votingSessionId: votingSessionId)),
//                         child: Builder(
//                           builder: (context) {
//                             switch (sessionStatus) {
//                               case VotingSessionStatus.initialized:
//                                 return ListViewWithCentralLabel(
//                                   label: 'Await here the beginning of the voting session',
//                                 );
//                               case VotingSessionStatus.work:
//                                 final currentStepDeadline = votingSession.currentStepDeadline!;
//                                 final currentParticipantIndex =
//                                     votingSession.currentParticipantIndex!;
//
//                                 return ListView(
//                                   children: [
//                                     SizedBox(height: 16),
//                                     Center(
//                                       child: CustomTimerCountdown(
//                                         label: 'Voting phase',
//                                         endTime: currentStepDeadline,
//                                       ),
//                                     ),
//                                     Divider(height: 24),
//                                     votingFormAndWorkViews[currentParticipantIndex],
//                                     SizedBox(height: 72),
//                                   ],
//                                 );
//                               case VotingSessionStatus.intermission:
//                                 final currentStepDeadline = votingSession.currentStepDeadline!;
//                                 return ListViewWithCentralWidget(
//                                   centralWidget: CustomTimerCountdown(
//                                     label: 'Intermission',
//                                     endTime: currentStepDeadline,
//                                   ),
//                                 );
//                               case VotingSessionStatus.review:
//                                 final currentStepDeadline = votingSession.currentStepDeadline!;
//
//                                 return ListView(
//                                   children: [
//                                     SizedBox(height: 16),
//                                     Center(
//                                       child: CustomTimerCountdown(
//                                         label: 'Review',
//                                         endTime: currentStepDeadline,
//                                       ),
//                                     ),
//                                     Divider(height: 24),
//                                     Form(
//                                       key: reviewFormKey,
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           ...votingFormAndWorkViews,
//                                           SizedBox(height: 72),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               case VotingSessionStatus.cancelled:
//                               case VotingSessionStatus.ended:
//                                 return VoidWidget();
//                             }
//                           },
//                         ),
//                       );
//                   }
//                 },
//               ),
//             ),
//           ),
//           floatingActionButton: Builder(
//             builder: (context) {
//               switch (state.status) {
//                 case BlocStatus.initial:
//                   return VoidWidget();
//                 case (BlocStatus.loading || BlocStatus.failure):
//                   if (!state.isInitialized) {
//                     return VoidWidget();
//                   } else {
//                     continue successCase;
//                   }
//                 successCase:
//                 case BlocStatus.success:
//                   final votingSessionBundle =
//                       state.votingSessionProcedureBundle!.votingSessionBundle;
//                   final votingSession = votingSessionBundle.votingSession;
//                   if (!votingSession.sessionStatus.isReview) {
//                     return VoidWidget();
//                   }
//                   return FilledButton(
//                     onPressed: () {
//                       if (reviewFormKey.currentState?.validate() ?? false) {
//                         final Map<VotingSessionParticipation, Map<VotingFormField, double>>
//                             votesPerParticipantMap = {};
//                         for (var entry in votesMap.entries) {
//                           final votingSessionParticipation = entry.key;
//                           final votingFormFieldAndController = entry.value;
//                           final Map<VotingFormField, double> votes = {};
//                           for (var votingFormFieldAndControllerEntry
//                               in votingFormFieldAndController.entries) {
//                             final votingFormField = votingFormFieldAndControllerEntry.key;
//                             final controller = votingFormFieldAndControllerEntry.value;
//                             votes.addAll({votingFormField: double.parse(controller.text)});
//                           }
//                           votesPerParticipantMap.addAll({votingSessionParticipation: votes});
//                         }
//                         context
//                             .read<SimpleJurorVotingProcedurePageBloc>()
//                             .add(SimpleJurorVotingProcedurePageSubmitVotes(
//                               simpleJurorId: simpleJurorId,
//                               votingSession: votingSessionBundle.votingSession,
//                               geoResPlace: state
//                                   .votingSessionProcedureBundle!.votingSessionBundle.geoResPlace,
//                               votesPerParticipantMap: votesPerParticipantMap,
//                               jurorId: profileId,
//                             ));
//                       }
//                     },
//                     child: Text('Submit'),
//                   );
//               }
//             },
//           ),
//         );
//       },
//     );
//   }
// }
