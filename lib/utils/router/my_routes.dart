// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// 
// import 'package:swift_contest/model/bundles/simple_juror_and_voting_session_bundle.dart';
// import 'package:swift_contest/utils/router/app_routes.dart';
// import 'package:swift_contest/view/pages/account_page.dart';
// import 'package:swift_contest/view/pages/inbox_page.dart';
// import 'package:swift_contest/view/pages/juror_pages/juror_contest_details_page/juror_contest_details_page.dart';
// import 'package:swift_contest/view/pages/juror_pages/juror_home_page.dart';
// import 'package:swift_contest/view/pages/juror_pages/juror_voting_procedure_page.dart';
// import 'package:swift_contest/view/pages/juror_pages/simple_juror_voting_procedure_page.dart';
// import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_creation_page.dart';
// import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_contest_details_page.dart';
// import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_edit_page.dart';
// import 'package:swift_contest/view/pages/organizer_pages/organizer_home_page.dart';
// import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_form_edit_page.dart';
// import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_procedure_page.dart';
// import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_result_details_page/organizer_voting_result_details_page.dart';
// import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_result_export_page.dart';
// import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_settings_page.dart';
// import 'package:swift_contest/view/pages/organizer_pages/organizer_work_details_page.dart';
// import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_contest_details_page.dart';
// import 'package:swift_contest/view/pages/participant_pages/participant_home_page.dart';
// import 'package:swift_contest/view/pages/participant_pages/participant_work_submit_page.dart';
// import 'package:swift_contest/view/pages/place_search_page.dart';
// import 'package:swift_contest/view/pages/root_page.dart';
// import 'package:swift_contest/view/pages/settings_page.dart';
// import 'package:swift_contest/view/pages/sign_in_page.dart';
// import 'package:swift_contest/view/pages/sign_in_verify_page.dart';
// import 'package:swift_contest/view/pages/sign_up_page.dart';
// import 'package:swift_contest/view/pages/sign_up_verify_page.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_contest_details_page_bloc/juror_contest_details_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_home_page_bloc/juror_home_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_voting_procedure_page_bloc/juror_voting_procedure_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_creation_page_bloc/organizer_contest_creation_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_edit_page_bloc/organizer_contest_edit_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_home_page_bloc/organizer_home_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_form_edit_page_bloc/organizer_voting_form_edit_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_procedure_page_bloc/organizer_voting_procedure_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_result_details_page_bloc/organizer_voting_result_details_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_result_export_page_bloc/organizer_voting_result_export_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_settings_page_bloc/organizer_voting_settings_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_work_details_page_bloc/organizer_work_details_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_contest_details_page_bloc/participant_contest_details_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_home_page_bloc/participant_home_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_work_submit_page_bloc/participant_work_submit_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/place_search_page_bloc/place_search_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_in_page_bloc/sign_in_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_in_verify_page_bloc/sign_in_verify_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_up_page_bloc/sign_up_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_up_verify_page_bloc/sign_up_verify_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/simple_juror_voting_procedure_page_bloc/simple_juror_voting_procedure_page_bloc.dart';
//
// class MyRoutes {
//   const MyRoutes._();
//
//   //* Root
//   static GoRoute root({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.root,
//       path: '/',
//       pageBuilder: (context, state) {
//         if (state.extra == null) {
//           return const MaterialPage(child: RootPage());
//         }
//         final delay = state.extra as int;
//         return MaterialPage(child: RootPage(delay: delay));
//       },
//       routes: routes,
//     );
//   }
//
//   // * SignIn
//   static GoRoute signIn({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.signIn,
//       path: '/sign_in',
//       pageBuilder: (context, state) {
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => SignInPageBloc(
//               authRepository: context.read(),
//               jurorRepository: context.read(),
//             ),
//             child: SignInPage(),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//
//   //* SignInVerify
//   static GoRoute signInVerify({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.signInVerify,
//       path: '/sign_in_verify',
//       pageBuilder: (context, state) {
//         final String email = state.extra as String;
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => SignInVerifyPageBloc(authRepository: context.read()),
//             child: SignInVerifyPage(email: email),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//
//   //* SignUp
//   static GoRoute signUp({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.signUp,
//       path: '/sign_up',
//       pageBuilder: (context, state) {
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => SignUpPageBloc(authRepository: context.read()),
//             child: SignUpPage(),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//
//   //* SignUpVerify
//   static GoRoute signUpVerify({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.signUpVerify,
//       path: '/sign_up_verify',
//       pageBuilder: (context, state) {
//         final String email = state.extra as String;
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => SignUpVerifyPageBloc(authRepository: context.read()),
//             child: SignUpVerifyPage(email: email),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//
//   //* Settings
//   static GoRoute settings({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.settings,
//       path: '/settings',
//       pageBuilder: (context, state) {
//         return MaterialPage(
//           child: SettingsPage(),
//         );
//       },
//       routes: routes,
//     );
//   }
//
//   //* Account
//   static GoRoute account({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.account,
//       path: '/account',
//       pageBuilder: (context, state) {
//         return MaterialPage(
//           child: AccountPage(),
//         );
//       },
//       routes: routes,
//     );
//   }
//
//   //* Inbox
//   static GoRoute inbox({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.inbox,
//       path: '/inbox',
//       pageBuilder: (context, state) {
//         return MaterialPage(
//           child: InboxPage(),
//         );
//       },
//       routes: routes,
//     );
//   }
//
//   //* PlaceSearch
//   static GoRoute placeSearch({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.placeSearch,
//       path: '/place_search',
//       pageBuilder: (context, state) {
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => PlaceSearchPageBloc(
//               googlePlaceRepository: context.read(),
//             ),
//             child: PlaceSearchPage(),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* OrganizerHome
//   static GoRoute organizerHome({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.organizerHome,
//       path: '/organizer_home',
//       pageBuilder: (context, state) {
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => OrganizerHomePageBloc(
//               organizerRepository: context.read(),
//             ),
//             child: OrganizerHomePage(),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* OrganizerContestCreation
//   static GoRoute organizerContestCreation({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.organizerContestCreation,
//       path: '/organizer_contest_creation',
//       pageBuilder: (context, state) {
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => OrganizerContestCreationPageBloc(
//               storageRepository: context.read(),
//               organizerRepository: context.read(),
//             ),
//             child: OrganizerContestCreationPage(),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* OrganizerContestDetails
//   static GoRoute organizerContestDetails({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.organizerContestDetails,
//       path: '/organizer_contest_details:contestId',
//       pageBuilder: (context, state) {
//         final String contestId = state.extra as String;
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => OrganizerContestDetailsPageBloc(
//               genericRepository: context.read(),
//               organizerRepository: context.read(),
//             ),
//             child: OrganizerContestDetailsPage(
//               contestId: contestId,
//             ),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* OrganizerContestEdit
//   static GoRoute organizerContestEdit({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.organizerContestEdit,
//       path: '/organizer_contest_edit',
//       pageBuilder: (context, state) {
//         final String contestId = state.extra as String;
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => OrganizerContestEditPageBloc(
//               genericRepository: context.read(),
//               organizerRepository: context.read(),
//               storageRepository: context.read(),
//             ),
//             child: OrganizerContestEditPage(
//               contestId: contestId,
//             ),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* OrganizerWorkDetails
//   static GoRoute organizerWorkDetails({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.organizerWorkDetails,
//       path: '/organizer_work_details',
//       pageBuilder: (context, state) {
//         final String participationId = state.extra as String;
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => OrganizerWorkDetailsPageBloc(
//               organizerRepository: context.read(),
//             ),
//             child: OrganizerWorkDetailsPage(participationId: participationId),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* OrganizerVotingFormEdit
//   static GoRoute organizerVotingFormEdit({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.organizerVotingFormEdit,
//       path: '/organizer_voting_form',
//       pageBuilder: (context, state) {
//         final String votingFormId = state.extra as String;
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => OrganizerVotingFormEditPageBloc(
//               genericRepository: context.read(),
//               organizerRepository: context.read(),
//             ),
//             child: OrganizerVotingFormEditPage(
//               votingFormId: votingFormId,
//             ),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* OrganizerVotingResultDetails
//   static GoRoute organizerVotingResultDetails({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.organizerVotingResultDetails,
//       path: '/organizer_voting_results',
//       pageBuilder: (context, state) {
//         final votingSessionId = state.extra as String;
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => OrganizerVotingResultDetailsPageBloc(
//               genericRepository: context.read(),
//               organizerRepository: context.read(),
//             ),
//             child: OrganizerVotingResultDetailsPage(
//               votingSessionId: votingSessionId,
//             ),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* OrganizerVotingResultExport
//   static GoRoute organizerVotingResultExport({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.organizerVotingResultExport,
//       path: '/organizer_export',
//       pageBuilder: (context, state) {
//         final String votingSessionId = state.extra as String;
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => OrganizerVotingResultExportPageBloc(
//               genericRepository: context.read(),
//               organizerRepository: context.read(),
//             ),
//             child: OrganizerVotingResultExportPage(votingSessionId: votingSessionId),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* OrganizerVotingSettings
//   static GoRoute organizerVotingSettings({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.organizerVotingSettings,
//       path: '/organizer_voting_settings',
//       pageBuilder: (context, state) {
//         final String contestId = state.extra as String;
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => OrganizerVotingSettingsPageBloc(
//               genericRepository: context.read(),
//               organizerRepository: context.read(),
//             ),
//             child: OrganizerVotingSettingsPage(contestId: contestId),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* OrganizerVotingProcedure
//   static GoRoute organizerVotingProcedure({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.organizerVotingProcedure,
//       path: '/organizer_voting_procedure',
//       pageBuilder: (context, state) {
//         final String votingSessionId = state.extra as String;
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => OrganizerVotingProcedurePageBloc(
//               genericRepository: context.read(),
//               organizerRepository: context.read(),
//             ),
//             child: OrganizerVotingProcedurePage(votingSessionId: votingSessionId),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* ParticipantHome
//   static GoRoute participantHome({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.participantHome,
//       path: '/participant_home',
//       pageBuilder: (context, state) {
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => ParticipantHomePageBloc(
//               participantRepository: context.read(),
//             ),
//             child: ParticipantHomePage(),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* ParticipantContestDetails
//   static GoRoute participantContestDetails({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.participantContestDetails,
//       path: '/participant_contest_details',
//       pageBuilder: (context, state) {
//         final String contestId = state.extra as String;
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => ParticipantContestDetailsPageBloc(
//               genericRepository: context.read(),
//               participantRepository: context.read(),
//             ),
//             child: ParticipantContestDetailsPage(contestId: contestId),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* ParticipantWorkSubmit
//   static GoRoute participantWorkSubmit({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.participantWorkSubmit,
//       path: '/participant_submit_work',
//       pageBuilder: (context, state) {
//         final String contestId = state.extra as String;
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => ParticipantWorkSubmitPageBloc(
//               storageRepository: context.read(),
//               participantRepository: context.read(),
//             ),
//             child: ParticipantWorkSubmitPage(contestId: contestId),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* JurorHome
//   static GoRoute jurorHome({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.jurorHome,
//       path: '/juror_home',
//       pageBuilder: (context, state) {
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => JurorHomePageBloc(
//               jurorRepository: context.read(),
//             ),
//             child: JurorHomePage(),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* JurorContestDetails
//   static GoRoute jurorContestDetails({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.jurorContestDetails,
//       path: '/juror_contest_details',
//       pageBuilder: (context, state) {
//         final String contestId = state.extra as String;
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => JurorContestDetailsPageBloc(
//               genericRepository: context.read(),
//               jurorRepository: context.read(),
//             ),
//             child: JurorContestDetailsPage(
//               contestId: contestId,
//             ),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* JurorVotingProcedure
//   static GoRoute jurorVotingProcedure({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.jurorVotingProcedure,
//       path: '/juror_voting_procedure',
//       pageBuilder: (context, state) {
//         final String votingSessionId = state.extra as String;
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => JurorVotingProcedurePageBloc(
//               genericRepository: context.read(),
//               jurorRepository: context.read(),
//             ),
//             child: JurorVotingProcedurePage(votingSessionId: votingSessionId),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
//   //* SimpleJurorVotingProcedure
//   static GoRoute simpleJurorVotingProcedure({List<GoRoute> routes = const []}) {
//     return GoRoute(
//       name: AppRoutes.simpleJurorVotingProcedure,
//       path: '/simple_juror_voting_procedure',
//       pageBuilder: (context, state) {
//         final SimpleJurorAndVotingSessionBundle simpleJurorAndVotingSessionBundle =
//         SimpleJurorAndVotingSessionBundle.fromJson(state.extra as Map<String, dynamic>);
//         return MaterialPage(
//           child: BlocProvider(
//             create: (context) => SimpleJurorVotingProcedurePageBloc(
//               genericRepository: context.read(),
//               jurorRepository: context.read(),
//             ),
//             child: SimpleJurorVotingProcedurePage(
//               simpleJurorId: simpleJurorAndVotingSessionBundle.simpleJuror.id,
//               votingSessionId: simpleJurorAndVotingSessionBundle.votingSession.id,
//             ),
//           ),
//         );
//       },
//       routes: routes,
//     );
//   }
// }