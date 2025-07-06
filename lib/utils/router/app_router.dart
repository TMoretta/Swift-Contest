import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        // Splash
        AutoRoute(
          initial: true,
          path: '/',
          page: SplashRoute.page,
        ),

        // Root
        AutoRoute(path: '/root', page: RootRoute.page),

        // Authentication
        AutoRoute(path: '/sign_in', page: SignInRoute.page),
        AutoRoute(path: '/sign_up', page: SignUpRoute.page),
        AutoRoute(path: '/sign_in_verify/:email', page: SignInVerifyRoute.page),
        AutoRoute(path: '/sign_up_verify/:email', page: SignUpVerifyRoute.page),

        // Generic
        AutoRoute(path: '/settings', page: SettingsRoute.page),
        AutoRoute(path: '/account', page: AccountRoute.page),
        AutoRoute(path: '/inbox', page: InboxRoute.page),
        AutoRoute(path: '/place_search', page: PlaceSearchRoute.page),

        // AutoRoute(
        //   path: '/organizer/home',
        //   page: EmptyShellRoute('OrganizerHomeRouter'),
        //   children: [
        //     AutoRoute(path: '', page: OrganizerHomeRoute.page, initial: true),
        //     AutoRoute(path: 'contest-creation', page: OrganizerContestCreationRoute.page),
        //     AutoRoute(path: 'contest-details/:contestId', page: OrganizerContestDetailsRoute.page),
        //     RedirectRoute(path: '*', redirectTo: ''), // Redirect unmatched paths
        //   ],
        // ),

        // Organizer
        AutoRoute(path: '/organizer_home', page: OrganizerHomeRoute.page),
        AutoRoute(path: '/organizer_contest_creation', page: OrganizerContestCreationRoute.page),
        AutoRoute(
            path: '/organizer_contest_details/:contestId', page: OrganizerContestDetailsRoute.page),
        AutoRoute(path: '/organizer_contest_edit/:contestId', page: OrganizerContestEditRoute.page),
        AutoRoute(
            path: '/organizer_voting_form/:votingFormId', page: OrganizerVotingFormEditRoute.page),
        AutoRoute(
            path: '/organizer_voting_result_details/:votingSessionId',
            page: OrganizerVotingResultDetailsRoute.page),
        AutoRoute(
            path: '/organizer_voting_result_export/:votingSessionId',
            page: OrganizerVotingResultExportRoute.page),
        AutoRoute(
            path: '/organizer_voting_procedure/:votingSessionId',
            page: OrganizerVotingProcedureRoute.page),
        AutoRoute(
            path: '/organizer_voting_settings/:contestId', page: OrganizerVotingSettingsRoute.page),
        AutoRoute(
            path: '/organizer_work_details/:participationId', page: OrganizerWorkDetailsRoute.page),

        // Participant
        AutoRoute(path: '/participant_home', page: ParticipantHomeRoute.page),
        AutoRoute(
            path: '/participant_contest_details/:contestId',
            page: ParticipantContestDetailsRoute.page),
        AutoRoute(
            path: '/participant_work_submit/:contestId', page: ParticipantWorkSubmitRoute.page),

        // Juror
        AutoRoute(path: '/juror_home', page: JurorHomeRoute.page),
        AutoRoute(path: '/juror_contest_details/:contestId', page: JurorContestDetailsRoute.page),
        AutoRoute(
            path: '/juror_voting_procedure/:votingSessionId', page: JurorVotingProcedureRoute.page),
        AutoRoute(
            path: '/simple_juror_voting_procedure/:votingSessionId/:simpleJurorId',
            page: SimpleJurorVotingProcedureRoute.page),
      ];
}

// @AutoRouterConfig(replaceInRouteName: 'Page,Route')
// class AppRouter extends RootStackRouter {
//   @override
//   List<AutoRoute> get routes => [
//     // --- Authentication flow ---
//     AutoRoute(
//       path: '/sign_in',
//       page: SignInRoute.page,
//       children: [
//         AutoRoute(path: 'verify/:email', page: SignInVerifyRoute.page),
//       ],
//     ),
//
//     AutoRoute(
//       path: '/sign_up',
//       page: SignUpRoute.page,
//       children: [
//         AutoRoute(path: 'verify/:email', page: SignUpVerifyRoute.page),
//       ],
//     ),
//
//     // --- Simple juror voting (public) ---
//     AutoRoute(
//       path: '/simple_juror_voting_procedure/:votingSessionId/:simpleJurorId',
//       page: SimpleJurorVotingProcedureRoute.page,
//     ),
//
//     // --- Root / splash ---
//     AutoRoute(path: '/', page: SplashRoute.page, initial: true),
//     AutoRoute(path: '/root', page: RootRoute.page),
//
//     // --- Organizer section ---
//     AutoRoute(
//       path: '/organizer_home',
//       page: OrganizerHomeRoute.page,
//       children: [
//         // common sub‐routes
//         AutoRoute(
//           path: 'settings',
//           page: SettingsRoute.page,
//           children: [
//             AutoRoute(path: 'account', page: AccountRoute.page),
//           ],
//         ),
//         AutoRoute(path: 'inbox', page: InboxRoute.page),
//
//         // contests
//         AutoRoute(
//           path: 'organizer_contest_creation',
//           page: OrganizerContestCreationRoute.page,
//         ),
//         AutoRoute(
//           path: 'organizer_contest_details/:contestId',
//           page: OrganizerContestDetailsRoute.page,
//           children: [
//             AutoRoute(path: 'edit', page: OrganizerContestEditRoute.page),
//             AutoRoute(
//                 path: 'work_details/:participationId', page: OrganizerWorkDetailsRoute.page),
//             AutoRoute(
//                 path: 'voting_form/:votingFormId', page: OrganizerVotingFormEditRoute.page),
//             AutoRoute(
//               path: 'voting_result_details/:votingSessionId',
//               page: OrganizerVotingResultDetailsRoute.page,
//               children: [
//                 AutoRoute(path: 'export', page: OrganizerVotingResultExportRoute.page),
//               ],
//             ),
//             AutoRoute(
//                 path: 'voting_settings/:contestId', page: OrganizerVotingSettingsRoute.page),
//             AutoRoute(
//                 path: 'voting_procedure/:votingSessionId',
//                 page: OrganizerVotingProcedureRoute.page),
//           ],
//         ),
//       ],
//     ),
//
//     // --- Participant section ---
//     AutoRoute(
//       path: '/participant_home',
//       page: ParticipantHomeRoute.page,
//       children: [
//         AutoRoute(
//           path: 'settings',
//           page: SettingsRoute.page,
//           children: [
//             AutoRoute(path: 'account', page: AccountRoute.page),
//           ],
//         ),
//         AutoRoute(path: 'inbox', page: InboxRoute.page),
//         AutoRoute(
//           path: 'participant_contest_details/:contestId',
//           page: ParticipantContestDetailsRoute.page,
//           children: [
//             AutoRoute(path: 'submit/:contestId', page: ParticipantWorkSubmitRoute.page),
//           ],
//         ),
//       ],
//     ),
//
//     // --- Juror section ---
//     AutoRoute(
//       path: '/juror_home',
//       page: JurorHomeRoute.page,
//       children: [
//         AutoRoute(
//           path: 'settings',
//           page: SettingsRoute.page,
//           children: [
//             AutoRoute(path: 'account', page: AccountRoute.page),
//           ],
//         ),
//         AutoRoute(path: 'inbox', page: InboxRoute.page),
//         AutoRoute(
//           path: 'simple_juror_voting_procedure/:votingSessionId/:simpleJurorId',
//           page: SimpleJurorVotingProcedureRoute.page,
//         ),
//         AutoRoute(
//           path: 'juror_contest_details/:contestId',
//           page: JurorContestDetailsRoute.page,
//           children: [
//             AutoRoute(
//                 path: 'voting_procedure/:votingSessionId',
//                 page: JurorVotingProcedureRoute.page),
//           ],
//         ),
//       ],
//     ),
//   ];
// }
