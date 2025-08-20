import 'package:auto_route/auto_route.dart';
import 'package:swift_contest/utils/router/auth_guard.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';

import 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  @override
  List<AutoRoute> get routes => [
        // Root
        AutoRoute(
          path: '/',
          page: RootRoute.page,
          initial: true,
          guards: [AuthGuard(authBloc: authBloc)],
        ),

        // Authentication
        AutoRoute(
          path: '/sign-in',
          page: SignInRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/sign-in-verify/:email',
          page: SignInVerifyRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/sign-up',
          page: SignUpRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/sign-up-verify/:email',
          page: SignUpVerifyRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),

        // Generic
        AutoRoute(
          path: '/settings',
          page: SettingsRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/account',
          page: AccountRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/inbox',
          page: InboxRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/place-search',
          page: PlaceSearchRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/unknown',
          page: UnknownRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
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
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/organizer-contest-creation',
          page: OrganizerContestCreationRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/organizer-contest-details/:contestId',
          page: OrganizerContestDetailsRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/organizer-contest-edit/:contestId',
          page: OrganizerContestEditRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/organizer-jury-details/:contestId/:juryId',
          page: OrganizerJuryDetailsRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/organizer-work-details/:participationId',
          page: OrganizerWorkDetailsRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/organizer-voting-form-edit/:votingFormId',
          page: OrganizerVotingFormEditRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/organizer-voting-settings/:contestId',
          page: OrganizerVotingSettingsRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/organizer-voting-procedure/:votingSessionId',
          page: OrganizerVotingProcedureRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/organizer-voting-results/:votingSessionId',
          page: OrganizerVotingResultsRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/organizer-jury-voting-results/:votingSessionJuryId',
          page: OrganizerJuryVotingResultsRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/organizer-juror-voting-results/:votingSessionJurorId',
          page: OrganizerJurorVotingResultsRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/organizer-jury-ranking-generation/:votingSessionJuryId',
          page: OrganizerJuryRankingGenerationRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),

        // Participant
        AutoRoute(
          path: '/participant-home',
          page: ParticipantHomeRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/participant-contest-details/:contestId',
          page: ParticipantContestDetailsRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/participant-work-submit/:contestId',
          page: ParticipantWorkSubmitRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),

        // Juror
        AutoRoute(
          path: '/juror-home',
          page: JurorHomeRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/juror-contest-details/:contestId',
          page: JurorContestDetailsRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/juror-qr-scanner',
          page: JurorVotingQrScannerRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/juror-voting-procedure/:votingSessionId',
          page: JurorVotingProcedureRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),
        AutoRoute(
          path: '/simple-juror-home',
          page: SimpleJurorHomeRoute.page,
          guards: [AuthGuard(authBloc: authBloc)],
        ),

        // Wildcard route for 404 Not Found pages. Must be the last route.
        RedirectRoute(path: '*', redirectTo: '/unknown'),
      ];
}
