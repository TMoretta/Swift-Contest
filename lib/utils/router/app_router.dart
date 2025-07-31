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
        AutoRoute(
          path: '/root',
          page: RootRoute.page,
        ),

        // Authentication
        AutoRoute(
          path: '/sign-in',
          page: SignInRoute.page,
        ),
        AutoRoute(
          path: '/sign-up',
          page: SignUpRoute.page,
        ),
        AutoRoute(
          path: '/sign-in-verify/:email',
          page: SignInVerifyRoute.page,
        ),
        AutoRoute(
          path: '/sign-up-verify/:email',
          page: SignUpVerifyRoute.page,
        ),

        // Generic
        AutoRoute(
          path: '/settings',
          page: SettingsRoute.page,
        ),
        AutoRoute(
          path: '/account',
          page: AccountRoute.page,
        ),
        AutoRoute(
          path: '/inbox',
          page: InboxRoute.page,
        ),
        AutoRoute(
          path: '/place-search',
          page: PlaceSearchRoute.page,
        ),

        // AutoRoute(
        //   path: '/organizer/home',
        //   page: EmptyShellRoute('OrganizerHomeRouter'),
        //   children: [
        //     AutoRoute(path: '', page: OrganizerHomeRoute.page, initial: true),
        //     // AutoRoute(
        //     //   path: 'contest-creation',
        //     //   page: OrganizerContestCreationRoute.page,
        //     // ),
        //     AutoRoute(
        //       path: 'contest-creation',
        //       page: EmptyShellRoute('OrganizerContestCreationRouter'),
        //       children: [
        //         AutoRoute(path: '', page: OrganizerContestCreationRoute.page, initial: true),
        //         AutoRoute(path: 'place-search', page: PlaceSearchRoute.page),
        //       ],
        //     ),
        //     // AutoRoute(path: 'contest-creation', page: OrganizerContestCreationRoute.page),
        //     AutoRoute(path: 'contest-details/:contestId', page: OrganizerContestDetailsRoute.page),
        //     RedirectRoute(path: '*', redirectTo: ''), // Redirect unmatched paths
        //   ],
        // ),

        // Organizer
        AutoRoute(
          path: '/organizer-home',
          page: OrganizerHomeRoute.page,
        ),
        AutoRoute(
          path: '/organizer-contest-creation',
          page: OrganizerContestCreationRoute.page,
        ),
        AutoRoute(
          path: '/organizer-contest-details/:contestId',
          page: OrganizerContestDetailsRoute.page,
        ),
        AutoRoute(
          path: '/organizer-contest-edit/:contestId',
          page: OrganizerContestEditRoute.page,
        ),
        AutoRoute(
          path: '/organizer-jury-details/:contestId/:juryId',
          page: OrganizerJuryDetailsRoute.page,
        ),
        AutoRoute(
          path: '/organizer-work-details/:participationId',
          page: OrganizerWorkDetailsRoute.page,
        ),
        AutoRoute(
          path: '/organizer-voting-form-edit/:votingFormId',
          page: OrganizerVotingFormEditRoute.page,
        ),
        AutoRoute(
          path: '/organizer-voting-settings/:contestId',
          page: OrganizerVotingSettingsRoute.page,
        ),
        AutoRoute(
          path: '/organizer-voting-procedure/:votingSessionId',
          page: OrganizerVotingProcedureRoute.page,
        ),
        AutoRoute(
          path: '/organizer-voting-results/:votingSessionId',
          page: OrganizerVotingResultsRoute.page,
        ),
        AutoRoute(
          path: '/organizer-jury-voting-results/:votingSessionJuryId',
          page: OrganizerJuryVotingResultsRoute.page,
        ),
        // AutoRoute(
        //   path: '/organizer-voting-result-export/:votingSessionId',
        //   page: OrganizerVotingResultExportRoute.page,
        // ),

        // Participant
        AutoRoute(
          path: '/participant-home',
          page: ParticipantHomeRoute.page,
        ),
        AutoRoute(
          path: '/participant-contest-details/:contestId',
          page: ParticipantContestDetailsRoute.page,
        ),
        AutoRoute(
          path: '/participant-work-submit/:contestId',
          page: ParticipantWorkSubmitRoute.page,
        ),

        // Juror
        AutoRoute(
          path: '/juror-home',
          page: JurorHomeRoute.page,
        ),
        AutoRoute(
          path: '/juror-contest-details/:contestId',
          page: JurorContestDetailsRoute.page,
        ),
        AutoRoute(
          path: '/juror-voting-procedure/:votingSessionId',
          page: JurorVotingProcedureRoute.page,
        ),
        // AutoRoute(
        //   path: '/simple-juror-voting-procedure/:votingSessionId/:simpleJurorId',
        //   page: SimpleJurorVotingProcedureRoute.page,
        // ),
      ];
}
