// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// 
// import 'package:swift_contest/model/bundles/simple_juror_and_voting_session_bundle.dart';
// import 'package:swift_contest/utils/router/app_routes.dart';
// import 'package:swift_contest/utils/router/auth_bloc_notifier.dart';
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
// import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
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
// import 'package:swift_contest/viewmodel/enums/auth_status.dart';
//
// //* GoRouter: routing service, the auth bloc is for redirect in base of the state of the authentication
// GoRouter getGoRouter({required AuthBloc authBloc}) {
//   return GoRouter(
//     refreshListenable: AuthBlocNotifier(authBloc: authBloc),
//     // Triggerato dai cambiamenti di stato dell'autenticazione
//     redirect: (context, state) {
//       final matchedLocation = state.matchedLocation; // Pagina corrente
//       final authState = context.read<AuthBloc>().state; // Stato dell'autenticazione
//
//       // Se la pagina corrente è root non fa nulla, dato che integra una reindirizzazione
//       // in base allo stato dell'autenticazione
//       if (matchedLocation == '/') {
//         return null;
//       }
//       // Se la pagina e' quella di votazione per giurati semplici non fa nulla perche' egli puo'
//       // votare anche senza autenticazione
//       if (matchedLocation == '/simple_juror_voting_procedure') {
//         return null;
//       }
//       // Se l'utente non è autenticato e prova ad andare in pagine diverse da quelle per l'autenticazione
//       // lo rendirizza alla pagina di signIn
//       if (authState.authStatus.isUnauthenticated &&
//           matchedLocation != '/sign_in' &&
//           matchedLocation != '/sign_up' &&
//           matchedLocation != '/sign_up_verify' &&
//           matchedLocation != '/sign_in_verify') {
//         return '/sign_in';
//       }
//       // Se l'utente è autenticato e prova ad andare in pagine per l'autenticazione lo reindirizza alla home
//       if (authState.authStatus.isAuthenticated &&
//           (matchedLocation == '/sign_in' ||
//               matchedLocation == '/sign_up' ||
//               matchedLocation == '/sign_up_verify' ||
//               matchedLocation == '/sign_in_verify')) {
//         return '/';
//       }
//       return null; // nessun redirect
//     },
//     initialLocation: '/',
//     initialExtra: 1,
//     routes: [
//       GoRoute(
//         name: AppRoutes.root,
//         path: '/',
//         pageBuilder: (context, state) {
//           if (state.extra == null) {
//             return MaterialPage(child: RootPage());
//           }
//           final delay = state.extra as int;
//           return MaterialPage(child: RootPage(delay: delay));
//         },
//       ),
//       //* SignIn: allow the user to sign in
//       GoRoute(
//         name: AppRoutes.signIn,
//         path: '/sign_in',
//         pageBuilder: (context, state) {
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => SignInPageBloc(
//                 authRepository: context.read(),
//                 jurorRepository: context.read(),
//               ),
//               child: SignInPage(),
//             ),
//           );
//         },
//       ),
//       //* SignInVerify: verify for otp sign in
//       GoRoute(
//         name: AppRoutes.signInVerify,
//         path: '/sign_in_verify',
//         pageBuilder: (context, state) {
//           final String email = state.extra as String;
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => SignInVerifyPageBloc(authRepository: context.read()),
//               child: SignInVerifyPage(email: email),
//             ),
//           );
//         },
//       ),
//       //* SignUp: allow the user to sign up
//       GoRoute(
//         name: AppRoutes.signUp,
//         path: '/sign_up',
//         pageBuilder: (context, state) {
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => SignUpPageBloc(authRepository: context.read()),
//               child: SignUpPage(),
//             ),
//           );
//         },
//       ),
//       //* SignUpVerify: verify for otp sign up
//       GoRoute(
//         name: AppRoutes.signUpVerify,
//         path: '/sign_up_verify',
//         pageBuilder: (context, state) {
//           final String email = state.extra as String;
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => SignUpVerifyPageBloc(authRepository: context.read()),
//               child: SignUpVerifyPage(email: email),
//             ),
//           );
//         },
//       ),
//       //* Settings
//       GoRoute(
//         name: AppRoutes.settings,
//         path: '/settings',
//         pageBuilder: (context, state) {
//           return MaterialPage(
//             child: SettingsPage(),
//           );
//         },
//       ),
//       //* Account: settings for the account
//       GoRoute(
//         name: AppRoutes.account,
//         path: '/account',
//         pageBuilder: (context, state) {
//           return MaterialPage(
//             child: AccountPage(),
//           );
//         },
//       ),
//       //* Inbox
//       GoRoute(
//         name: AppRoutes.inbox,
//         path: '/inbox',
//         pageBuilder: (context, state) {
//           return MaterialPage(
//             child: InboxPage(),
//           );
//         },
//       ),
//       //* PlaceSearch
//       GoRoute(
//         name: AppRoutes.placeSearch,
//         path: '/place_search',
//         pageBuilder: (context, state) {
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => PlaceSearchPageBloc(
//                 googlePlaceRepository: context.read(),
//               ),
//               child: PlaceSearchPage(),
//             ),
//           );
//         },
//       ),
//       //* OrganizerHome
//       GoRoute(
//         name: AppRoutes.organizerHome,
//         path: '/organizer_home',
//         pageBuilder: (context, state) {
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => OrganizerHomePageBloc(
//                 organizerRepository: context.read(),
//               ),
//               child: OrganizerHomePage(),
//             ),
//           );
//         },
//       ),
//       //* Organizer contest creation
//       GoRoute(
//         name: AppRoutes.organizerContestCreation,
//         path: '/organizer_contest_creation',
//         pageBuilder: (context, state) {
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => OrganizerContestCreationPageBloc(
//                 storageRepository: context.read(),
//                 organizerRepository: context.read(),
//               ),
//               child: OrganizerContestCreationPage(),
//             ),
//           );
//         },
//       ),
//       //* Organizer contest details
//       GoRoute(
//         name: AppRoutes.organizerContestDetails,
//         path: '/organizer_contest_details',
//         pageBuilder: (context, state) {
//           final String contestId = state.extra as String;
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => OrganizerContestDetailsPageBloc(
//                 genericRepository: context.read(),
//                 organizerRepository: context.read(),
//               ),
//               child: OrganizerContestDetailsPage(
//                 contestId: contestId,
//               ),
//             ),
//           );
//         },
//       ),
//       //* Organizer contest edit
//       GoRoute(
//         name: AppRoutes.organizerContestEdit,
//         path: '/organizer_contest_edit',
//         pageBuilder: (context, state) {
//           final String contestId = state.extra as String;
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => OrganizerContestEditPageBloc(
//                 genericRepository: context.read(),
//                 organizerRepository: context.read(),
//                 storageRepository: context.read(),
//               ),
//               child: OrganizerContestEditPage(
//                 contestId: contestId,
//               ),
//             ),
//           );
//         },
//       ),
//       //* Work details
//       GoRoute(
//         name: AppRoutes.organizerWorkDetails,
//         path: '/organizer_work_details',
//         pageBuilder: (context, state) {
//           final String participationId = state.extra as String;
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => OrganizerWorkDetailsPageBloc(
//                 organizerRepository: context.read(),
//               ),
//               child: OrganizerWorkDetailsPage(participationId: participationId),
//             ),
//           );
//         },
//       ),
//       //* Voting form edit
//       GoRoute(
//         name: AppRoutes.organizerVotingFormEdit,
//         path: '/organizer_voting_form',
//         pageBuilder: (context, state) {
//           final String votingFormId = state.extra as String;
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => OrganizerVotingFormEditPageBloc(
//                 genericRepository: context.read(),
//                 organizerRepository: context.read(),
//               ),
//               child: OrganizerVotingFormEditPage(
//                 votingFormId: votingFormId,
//               ),
//             ),
//           );
//         },
//       ),
//       //* Voting results page
//       GoRoute(
//         name: AppRoutes.organizerVotingResultDetails,
//         path: '/organizer_voting_results',
//         pageBuilder: (context, state) {
//           final votingSessionId = state.extra as String;
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => OrganizerVotingResultDetailsPageBloc(
//                 genericRepository: context.read(),
//                 organizerRepository: context.read(),
//               ),
//               child: OrganizerVotingResultDetailsPage(
//                 votingSessionId: votingSessionId,
//               ),
//             ),
//           );
//         },
//       ),
//       //* Voting results export page
//       GoRoute(
//         name: AppRoutes.organizerVotingResultExport,
//         path: '/organizer_export',
//         pageBuilder: (context, state) {
//           final String votingSessionId = state.extra as String;
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => OrganizerVotingResultExportPageBloc(
//                 genericRepository: context.read(),
//                 organizerRepository: context.read(),
//               ),
//               child: OrganizerVotingResultExportPage(votingSessionId: votingSessionId),
//             ),
//           );
//         },
//       ),
//       //* Voting settings page
//       GoRoute(
//         name: AppRoutes.organizerVotingSettings,
//         path: '/organizer_voting_settings',
//         pageBuilder: (context, state) {
//           final String contestId = state.extra as String;
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => OrganizerVotingSettingsPageBloc(
//                 genericRepository: context.read(),
//                 organizerRepository: context.read(),
//               ),
//               child: OrganizerVotingSettingsPage(contestId: contestId),
//             ),
//           );
//         },
//       ),
//       //* Voting procedure page
//       GoRoute(
//         name: AppRoutes.organizerVotingProcedure,
//         path: '/organizer_voting_procedure',
//         pageBuilder: (context, state) {
//           final String votingSessionId = state.extra as String;
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => OrganizerVotingProcedurePageBloc(
//                 genericRepository: context.read(),
//                 organizerRepository: context.read(),
//               ),
//               child: OrganizerVotingProcedurePage(votingSessionId: votingSessionId),
//             ),
//           );
//         },
//       ),
//       //* ParticipantHome
//       GoRoute(
//         name: AppRoutes.participantHome,
//         path: '/participant_home',
//         pageBuilder: (context, state) {
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => ParticipantHomePageBloc(
//                 participantRepository: context.read(),
//               ),
//               child: ParticipantHomePage(),
//             ),
//           );
//         },
//       ),
//       //* ParticipantContestDetails
//       GoRoute(
//         name: AppRoutes.participantContestDetails,
//         path: '/participant_contest_details',
//         pageBuilder: (context, state) {
//           final String contestId = state.extra as String;
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => ParticipantContestDetailsPageBloc(
//                 genericRepository: context.read(),
//                 participantRepository: context.read(),
//               ),
//               child: ParticipantContestDetailsPage(contestId: contestId),
//             ),
//           );
//         },
//       ),
//       //* ParticipantWorkSubmit
//       GoRoute(
//         name: AppRoutes.participantWorkSubmit,
//         path: '/participant_submit_work',
//         pageBuilder: (context, state) {
//           final String contestId = state.extra as String;
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => ParticipantWorkSubmitPageBloc(
//                 storageRepository: context.read(),
//                 participantRepository: context.read(),
//               ),
//               child: ParticipantWorkSubmitPage(contestId: contestId),
//             ),
//           );
//         },
//       ),
//       //* JurorHome
//       GoRoute(
//         name: AppRoutes.jurorHome,
//         path: '/juror_home',
//         pageBuilder: (context, state) {
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => JurorHomePageBloc(
//                 jurorRepository: context.read(),
//               ),
//               child: JurorHomePage(),
//             ),
//           );
//         },
//       ),
//       //* Juror contest details page
//       GoRoute(
//         name: AppRoutes.jurorContestDetails,
//         path: '/juror_contest_details',
//         pageBuilder: (context, state) {
//           final String contestId = state.extra as String;
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => JurorContestDetailsPageBloc(
//                 genericRepository: context.read(),
//                 jurorRepository: context.read(),
//               ),
//               child: JurorContestDetailsPage(
//                 contestId: contestId,
//               ),
//             ),
//           );
//         },
//       ),
//       //* JurorVotingProcedure
//       GoRoute(
//         name: AppRoutes.jurorVotingProcedure,
//         path: '/juror_voting_procedure',
//         pageBuilder: (context, state) {
//           final String votingSessionId = state.extra as String;
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => JurorVotingProcedurePageBloc(
//                 genericRepository: context.read(),
//                 jurorRepository: context.read(),
//               ),
//               child: JurorVotingProcedurePage(votingSessionId: votingSessionId),
//             ),
//           );
//         },
//       ),
//       //* SimpleJurorVotingProcedure
//       GoRoute(
//         name: AppRoutes.simpleJurorVotingProcedure,
//         path: '/simple_juror_voting_procedure',
//         pageBuilder: (context, state) {
//           final SimpleJurorAndVotingSessionBundle simpleJurorAndVotingSessionBundle =
//           SimpleJurorAndVotingSessionBundle.fromJson(state.extra as Map<String, dynamic>);
//           return MaterialPage(
//             child: BlocProvider(
//               create: (context) => SimpleJurorVotingProcedurePageBloc(
//                 genericRepository: context.read(),
//                 jurorRepository: context.read(),
//               ),
//               child: SimpleJurorVotingProcedurePage(
//                 simpleJurorId: simpleJurorAndVotingSessionBundle.simpleJuror.id,
//                 votingSessionId: simpleJurorAndVotingSessionBundle.votingSession.id,
//               ),
//             ),
//           );
//         },
//       ),
//     ],
//   );
// }
//
//  //* GoRouter: routing service, the auth bloc is for redirect in base of the state of the authentication
//  GoRouter getGoRouter({required AuthBloc authBloc}) {
//    return GoRouter(
//      refreshListenable: AuthBlocNotifier(authBloc: authBloc),
//      // Triggerato dai cambiamenti di stato dell'autenticazione
//      redirect: (context, state) {
//        final matchedLocation = state.matchedLocation; // Pagina corrente
//        final authState = context.read<AuthBloc>().state; // Stato dell'autenticazione
//
//        // Se la pagina corrente è root non fa nulla, dato che integra una reindirizzazione
//        // in base allo stato dell'autenticazione
//        if (matchedLocation == '/') {
//          return null;
//        }
//        // Se la pagina e' quella di votazione per giurati semplici non fa nulla perche' egli puo'
//        // votare anche senza autenticazione
//        if (matchedLocation == '/simple_juror_voting_procedure') {
//          return null;
//        }
//        // Se l'utente non è autenticato e prova ad andare in pagine diverse da quelle per l'autenticazione
//        // lo rendirizza alla pagina di signIn
//        if (authState.authStatus.isUnauthenticated &&
//            matchedLocation != '/sign_in' &&
//            matchedLocation != '/sign_up' &&
//            matchedLocation != '/sign_up_verify' &&
//            matchedLocation != '/sign_in_verify') {
//          return '/sign_in';
//        }
//        // Se l'utente è autenticato e prova ad andare in pagine per l'autenticazione lo reindirizza alla home
//        if (authState.authStatus.isAuthenticated &&
//            (matchedLocation == '/sign_in' ||
//                matchedLocation == '/sign_up' ||
//                matchedLocation == '/sign_up_verify' ||
//                matchedLocation == '/sign_in_verify')) {
//          return '/';
//        }
//        return null; // nessun redirect
//      },
//      initialLocation: '/',
//      initialExtra: 1,
//      routes: [
//        MyRoutes.signIn(
//          routes: [
//            MyRoutes.signInVerify(),
//          ],
//        ),
//        MyRoutes.signUp(
//          routes: [
//            MyRoutes.signUpVerify(),
//          ],
//        ),
//        MyRoutes.simpleJurorVotingProcedure(),
//        MyRoutes.root(),
//        MyRoutes.organizerHome(
//          routes: [
//            MyRoutes.settings(routes: [
//              MyRoutes.account(),
//            ],),
//            MyRoutes.inbox(),
//            MyRoutes.organizerContestCreation(),
//            MyRoutes.organizerContestDetails(
//              routes: [
//                MyRoutes.organizerContestEdit(),
//                MyRoutes.organizerWorkDetails(),
//                MyRoutes.organizerVotingFormEdit(),
//                MyRoutes.organizerVotingResultDetails(
//                  routes: [
//                    MyRoutes.organizerVotingResultExport(),
//                  ],
//                ),
//                MyRoutes.organizerVotingSettings(),
//                MyRoutes.organizerVotingProcedure(),
//              ],
//            ),
//          ],
//        ),
//        MyRoutes.participantHome(
//          routes: [
//            MyRoutes.settings(routes: [
//              MyRoutes.account(),
//            ],),
//            MyRoutes.inbox(),
//            MyRoutes.participantContestDetails(
//              routes: [
//                MyRoutes.participantWorkSubmit(),
//              ],
//            ),
//          ],
//        ),
//        MyRoutes.jurorHome(
//          routes: [
//            MyRoutes.settings(routes: [
//              MyRoutes.account(),
//            ],),
//            MyRoutes.inbox(),
//            MyRoutes.simpleJurorVotingProcedure(),
//            MyRoutes.jurorContestDetails(
//              routes: [
//                MyRoutes.jurorVotingProcedure(),
//              ],
//            ),
//          ],
//        ),
//      ],
//    );
//  }
