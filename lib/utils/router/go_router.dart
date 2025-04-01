import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/view/pages/home_page.dart';
import 'package:swift_contest/view/pages/juror_pages/juror_contest_details_page/juror_contest_details_page.dart';
import 'package:swift_contest/view/pages/juror_pages/juror_home_page.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_creation_page.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_contest_details_page.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_home_page.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_form_edit_page.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_settings_page.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_work_details_page.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_contest_details_page.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_home_page.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_work_submit_page.dart';
import 'package:swift_contest/view/pages/settings_page.dart';
import 'package:swift_contest/view/pages/sign_in_page.dart';
import 'package:swift_contest/view/pages/sign_up_page.dart';
import 'package:swift_contest/view/pages/splash_page.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';

GoRouter getGoRouter({required AuthBloc authBloc}) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        name: AppRouter.splash,
        path: '/splash',
        pageBuilder: (context, state) {
          return MaterialPage(child: SplashPage());
        },
      ),
      GoRoute(
        name: AppRouter.signIn,
        path: '/signin',
        pageBuilder: (context, state) {
          return MaterialPage(child: SignInPage());
        },
      ),
      GoRoute(
        name: AppRouter.signUp,
        path: '/signup',
        pageBuilder: (context, state) {
          return MaterialPage(child: SignUpPage());
        },
      ),
      GoRoute(
        name: AppRouter.root,
        path: '/',
        pageBuilder: (context, state) {
          return MaterialPage(child: HomePage());
        },
      ),
      GoRoute( //Only to dispatch to the correct home page based on the role
        name: AppRouter.home,
        path: '/home',
        pageBuilder: (context, state) {
          return MaterialPage(child: HomePage());
        },
      ),
      GoRoute(
        name: AppRouter.settings,
        path: '/settings',
        pageBuilder: (context, state) {
          return MaterialPage(child: SettingsPage());
        },
      ),
      GoRoute(
        name: AppRouter.organizerHome,
        path: '/home/organizer',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: OrganizerHomePage(),
          );
        },
        routes: [
          GoRoute(
            name: AppRouter.organizerContestDetails,
            path: '/contest_details',
            pageBuilder: (context, state) {
              if (state.extra == null) {
                return MaterialPage(
                  child: Scaffold(
                    appBar: CustomAppBar(title: 'Contest Details'),
                    body: Center(
                      child: Text(
                          'You can not navigate to this page without providing a valid contest'),
                    ),
                  ),
                );
              }
              final contestId = state.extra as String;
              return MaterialPage(
                  child: OrganizerContestDetailsPage(
                contestId: contestId,
              ));
            },
            routes: [
              GoRoute(
                name: AppRouter.organizerWorkDetails,
                path: '/work_details',
                pageBuilder: (context, state) {
                  if (state.extra == null) {
                    return MaterialPage(
                      child: Scaffold(
                        appBar: CustomAppBar(title: 'Work Details'),
                        body: Center(
                          child: Text('You can not navigate to this page directly.'),
                        ),
                      ),
                    );
                  }
                  final participantAndWorkJson = state.extra as Map<String, dynamic>;
                  return MaterialPage(
                      child:
                          OrganizerWorkDetailsPage(participantAndWorkJson: participantAndWorkJson));
                },
              ),
              GoRoute(
                name: AppRouter.organizerVotingFormEdit,
                path: '/voting_form',
                pageBuilder: (context, state) {
                  if (state.extra == null) {
                    return MaterialPage(
                      child: Scaffold(
                        appBar: CustomAppBar(title: 'Voting form'),
                        body: Center(
                          child: Text('You can not navigate to this page directly.'),
                        ),
                      ),
                    );
                  }
                  final Map<String, dynamic> votingFormPlusContestIdJson =
                      state.extra as Map<String, dynamic>;
                  final String contestId = votingFormPlusContestIdJson['_contest_id'] as String;
                  votingFormPlusContestIdJson.remove('_contest_id');
                  final Map<String, dynamic> votingFormJson = votingFormPlusContestIdJson;
                  return MaterialPage(
                      child: OrganizerVotingFormEditPage(
                    contestId: contestId,
                    votingFormJson: votingFormJson,
                  ));
                },
              ),
              GoRoute(
                name: AppRouter.organizerVotingSettings,
                path: '/voting_settings',
                pageBuilder: (context, state) {
                  final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
                  return MaterialPage(child: OrganizerVotingSettingsPage(data: data));
                },
              )
            ],
          ),
          GoRoute(
            name: AppRouter.organizerContestCreation,
            path: '/contest_creation',
            pageBuilder: (context, state) {
              return MaterialPage(child: OrganizerContestCreationPage());
            },
          ),
        ],
      ),
      GoRoute(
        name: AppRouter.participantHome,
        path: '/home/participant',
        pageBuilder: (context, state) => MaterialPage(child: ParticipantHomePage()),
        routes: [
          GoRoute(
            name: AppRouter.participantContestDetails,
            path: '/contest_details',
            pageBuilder: (context, state) {
              if (state.extra == null) {
                return MaterialPage(
                  child: Scaffold(
                    appBar: CustomAppBar(title: 'Contest Details'),
                    body: Center(
                      child: Text('You can not navigate to this page directly'),
                    ),
                  ),
                );
              }
              final contestId = state.extra as String;
              return MaterialPage(
                child: ParticipantContestDetailsPage(contestId: contestId),
              );
            },
                routes: [
                  GoRoute(
                    name: AppRouter.participantWorkSubmit,
                    path: '/work_submit',
                    pageBuilder: (context, state) {
                      if (state.extra == null) {
                        return MaterialPage(
                          child: Scaffold(
                            appBar: CustomAppBar(title: 'Work Submit'),
                            body: Center(
                              child: Text('You can not navigate to this page directly'),
                            ),
                          ),
                        );
                      }
                      final contestId = state.extra as String;
                      return MaterialPage(
                          child: ParticipantWorkSubmitPage(contestId: contestId));
                    },
                  ),
                ],
          ),
        ],
      ),
      GoRoute(
        name: AppRouter.jurorHome,
        path: '/home/juror',
        pageBuilder: (context, state) => MaterialPage(child: JurorHomePage()),
        routes: [
          GoRoute(
              name: AppRouter.jurorContestDetails,
              path: '/contest_details',
              pageBuilder: (context, state) {
                if (state.extra == null) {
                  return MaterialPage(
                    child: Scaffold(
                      appBar: CustomAppBar(title: 'Contest Details'),
                      body: Center(
                        child: Text('You can not navigate to this page directly'),
                      ),
                    ),
                  );
                }
                final contestId = state.extra as String;
                return MaterialPage(
                  child: JurorContestDetailsPage(contestId: contestId),
                );
              }),
        ],
      ),
    ],
    refreshListenable: AppAuthBlocNotifier(authBloc: authBloc),
    redirect: (context, state) {
      final matchedLocation = state.matchedLocation;
      final authState = context.read<AuthBloc>().state;

      if (matchedLocation == '/splash') {
        return null;
      }
      if (authState.status.isUnauthenticated &&
          matchedLocation != '/signin' &&
          matchedLocation != '/signup') {
        return '/signin';
      }
      if (authState.status.isAuthenticated &&
          (matchedLocation == '/signin' || matchedLocation == '/signup')) {
        return '/home';
      }
      return null; // nessun redirect
    },
  );
}

//* AppRouter
final class AppRouter {
  const AppRouter._();

  static const String root = 'root';
  static const String splash = 'splash';
  static const String signIn = 'signIn';
  static const String signUp = 'signUp';
  static const String home = 'home';
  static const String settings = 'settings';

  static const String organizerHome = 'organizerHome';
  static const String organizerContestCreation = 'organizerContestCreation';
  static const String organizerContestDetails = 'organizerContestDetails';
  static const String organizerWorkDetails = 'organizerWorkDetails';
  static const String organizerVotingFormEdit = 'organizerVotingFormEdit';
  static const String organizerVotingSettings = 'organizerVotingSettings';

  static const String participantHome = 'participantHome';
  static const String participantContestDetails = 'participantContestDetails';
  static const String participantWorkSubmit = 'participantWorkSubmit';

  static const String jurorHome = 'jurorHome';
  static const String jurorContestDetails = 'jurorContestDetails';
}

//* AppAuthBlocNotifier
class AppAuthBlocNotifier extends ChangeNotifier {
  final AuthBloc authBloc;
  late final StreamSubscription _subscription;

  AppAuthBlocNotifier({required this.authBloc}) {
    _subscription = authBloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
