import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/view/pages/account_page.dart';
import 'package:swift_contest/view/pages/juror_pages/juror_contest_details_page/juror_contest_details_page.dart';
import 'package:swift_contest/view/pages/juror_pages/juror_home_page.dart';
import 'package:swift_contest/view/pages/juror_pages/juror_voting_procedure_page.dart';
import 'package:swift_contest/view/pages/juror_pages/simple_juror_voting_procedure_page.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_creation_page.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_contest_details_page.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_home_page.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_form_edit_page.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_procedure_page.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_results_export_page.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_results_page.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_settings_page.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_work_details_page.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_contest_details_page.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_home_page.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_work_submit_page.dart';
import 'package:swift_contest/view/pages/settings_page.dart';
import 'package:swift_contest/view/pages/sign_in_page.dart';
import 'package:swift_contest/view/pages/sign_up_page.dart';
import 'package:swift_contest/view/pages/sign_in_verify_page.dart';
import 'package:swift_contest/view/pages/sign_up_verify_page.dart';
import 'package:swift_contest/view/pages/splash_page.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/enums/auth_status.dart';

// Servizio di routing per l'app, l'auth bloc serve per reindirizzare in base allo stato dell'autenticazione
GoRouter getGoRouter({required AuthBloc authBloc}) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // La pagina di splash verifica lo stato dell'autenticazione e reindirizza, nel mentre mostra il logo
      GoRoute(
        name: AppRouter.splash,
        path: '/splash',
        pageBuilder: (context, state) {
          return MaterialPage(child: SplashPage());
        },
      ),
      GoRoute(
        name: AppRouter.signIn,
        path: '/sign_in',
        pageBuilder: (context, state) {
          return MaterialPage(child: SignInPage());
        },
        routes: [
          GoRoute(
            name: AppRouter.signInVerify,
            path: '/verify',
            pageBuilder: (context, state) {
              return MaterialPage(child: SignInVerifyPage(email: state.extra! as String));
            },
          ),
        ],
      ),
      GoRoute(
        name: AppRouter.signUp,
        path: '/sign_up',
        pageBuilder: (context, state) {
          return MaterialPage(child: SignUpPage());
        },
        routes: [
          GoRoute(
            name: AppRouter.signUpVerify,
            path: '/verify',
            pageBuilder: (context, state) {
              return MaterialPage(child: SignUpVerifyPage(email: state.extra! as String));
            },
          ),
        ],
      ),
      GoRoute(
        name: AppRouter.root,
        path: '/',
        pageBuilder: (context, state) {
          return MaterialPage(child: SplashPage());
        },
      ),
      // GoRoute(
      //   // Pagina per selezionare la home in base al ruole preferito dell'utente
      //   name: AppRouter.home,
      //   path: '/home',
      //   pageBuilder: (context, state) {
      //     return MaterialPage(child: HomePage());
      //   },
      // ),
      GoRoute(
        name: AppRouter.settings,
        path: '/settings',
        pageBuilder: (context, state) {
          return MaterialPage(child: SettingsPage());
        },
        routes: [
          GoRoute(
            name: AppRouter.account,
            path: '/account',
            pageBuilder: (context, state) {
              return MaterialPage(child: AccountPage());
            },
          ),
        ],
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
            name: AppRouter.organizerContestCreation,
            path: '/contest_creation',
            pageBuilder: (context, state) {
              return MaterialPage(child: OrganizerContestCreationPage());
            },
          ),
          GoRoute(
            name: AppRouter.organizerContestDetails,
            path: '/contest_details',
            pageBuilder: (context, state) {
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
                  final List<Map<String, dynamic>> votingFormFieldsJson =
                      state.extra as List<Map<String, dynamic>>;
                  return MaterialPage(
                      child: OrganizerVotingFormEditPage(
                    votingFormFieldsJson: votingFormFieldsJson,
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
                routes: [
                  GoRoute(
                    name: AppRouter.organizerVotingProcedure,
                    path: '/voting_procedure',
                    pageBuilder: (context, state) {
                      final String contestId = state.extra! as String;
                      return MaterialPage(
                          child: OrganizerVotingProcedurePage(contestId: contestId));
                    },
                  ),
                ],
              ),
              GoRoute(
                name: AppRouter.organizerVotingResults,
                path: '/voting_results',
                pageBuilder: (context, state) {
                  final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
                  final contestId = data['contest_id'];
                  final votingSessionId = data['voting_session_id'];
                  return MaterialPage(
                      child: OrganizerVotingResultsPage(
                    contestId: contestId,
                    votingSessionId: votingSessionId,
                  ));
                },
                routes: [
                  GoRoute(
                    name: AppRouter.organizerVotingResultsExport,
                    path: '/export',
                    pageBuilder: (context, state) {
                      final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
                      return MaterialPage(child: OrganizerVotingResultsExportPage(data: data));
                    },
                  ),
                ],
              ),
            ],
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
                  return MaterialPage(child: ParticipantWorkSubmitPage(contestId: contestId));
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
            },
            routes: [
              GoRoute(
                name: AppRouter.jurorVotingProcedure,
                path: '/voting_procedure',
                pageBuilder: (context, state) {
                  final contestId = state.extra! as String;
                  return MaterialPage(child: JurorVotingProcedurePage(contestId: contestId));
                },
              ),
            ],
          ),
          GoRoute(
            name: AppRouter.simpleJurorVotingProcedure,
            path: '/simple_voting_procedure',
            pageBuilder: (context, state) {
              final jsonData = state.extra! as Map<String, dynamic>;
              return MaterialPage(
                child: SimpleJurorVotingProcedurePage(jsonData: jsonData),
              );
            },
          ),
        ],
      ),
    ],
    refreshListenable: AppAuthBlocNotifier(authBloc: authBloc),
    // Triggerato dai cambiamenti di stato dell'autenticazione
    redirect: (context, state) {
      final matchedLocation = state.matchedLocation; // Pagina corrente
      final authState = context.read<AuthBloc>().state; // Stato dell'autenticazione

      // Se la pagina corrente è splash non fa nulla, dato che la splash integra una reindirizzazione
      // in base allo stato dell'autenticazione
      if (matchedLocation == '/splash') {
        return null;
      }
      // Se l'utente non è autenticato e prova ad andare in pagine diverse da quelle per l'autenticazione
      // lo rendirizza alla pagina di signIn
      if (authState.authStatus.isUnauthenticated &&
          matchedLocation != '/sign_in' &&
          matchedLocation != '/sign_up' &&
          matchedLocation != '/sign_up/verify' &&
          matchedLocation != '/sign_in/verify') {
        return '/sign_in';
      }
      // Se l'utente è autenticato e prova ad andare in pagine per l'autenticazione lo reindirizza alla home
      if (authState.authStatus.isAuthenticated &&
          (matchedLocation == '/sign_in' ||
              matchedLocation == '/sign_up' ||
              matchedLocation == '/sign_up/verify' ||
              matchedLocation == '/sign_in/verify')) {
        return '/splash';
      }
      return null; // nessun redirect
    },
  );
}

// Contiene tutte le possibili routes per l'app
final class AppRouter {
  const AppRouter._(); // Costruttore privato per non instanziare la classe

  // Routes generiche
  static const String root = 'root';
  static const String splash = 'splash';
  static const String signIn = 'signIn';
  static const String signUp = 'signUp';
  // static const String home = 'home';
  static const String settings = 'settings';
  static const String account = 'account';
  static const String signInVerify = 'signInVerify';
  static const String signUpVerify = 'signUpVerify';

  // Routes organizzatore
  static const String organizerHome = 'organizerHome';
  static const String organizerContestCreation = 'organizerContestCreation';
  static const String organizerContestDetails = 'organizerContestDetails';
  static const String organizerWorkDetails = 'organizerWorkDetails';
  static const String organizerVotingFormEdit = 'organizerVotingFormEdit';
  static const String organizerVotingSettings = 'organizerVotingSettings';
  static const String organizerVotingProcedure = 'organizerVotingProcedure';
  static const String organizerVotingResults = 'organizerVotingResults';
  static const String organizerVotingResultsExport = 'organizerVotingResultsExport';

  // Routes partecipanti
  static const String participantHome = 'participantHome';
  static const String participantContestDetails = 'participantContestDetails';
  static const String participantWorkSubmit = 'participantWorkSubmit';

  // Routes giurati e giurati semplici
  static const String jurorHome = 'jurorHome';
  static const String jurorContestDetails = 'jurorContestDetails';
  static const String jurorVotingProcedure = 'jurorVotingProcedure';
  static const String simpleJurorVotingProcedure = 'simpleJurorVotingProcedure';
}

// Ascolta i cambiamenti di stato dell'AuthBloc
// Assegnato al go router per reindirizzare in base allo stato dell'autenticazione
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
