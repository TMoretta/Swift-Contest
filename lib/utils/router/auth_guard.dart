import 'package:auto_route/auto_route.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/types/auth_status.dart';

import 'app_router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  final AuthBloc authBloc;

  AuthGuard({required this.authBloc});

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // 1. Prendi lo stato corrente dall'AuthBloc
    final authStatus = authBloc.state.authStatus;
    bool isAnonymous = false;
    if (authStatus.isAuthenticated) {
      isAnonymous = authBloc.state.account?.isAnonymous ?? false;
    }

    // 2. Ricava la rotta di destinazione (il "path")
    //    AutoRoute ti espone il path di PageRouteInfo in .path
    final targetPath = resolver.route.path.split('/:').first;

    // 3. Se siamo alla root o alla pagina di errore, prosegui senza controlli.
    //    La RootPage gestisce la sua logica di reindirizzamento.
    //    La UnknownPage deve essere sempre accessibile.
    if (targetPath == '/' || targetPath == '/unknown') {
      resolver.next();
      return;
    }

    // 4. Se NON autenticato e non sto andando su pagine di auth, redirigi al login
    const authPaths = ['/sign-in', '/sign-in-verify', '/sign-up', '/sign-up-verify'];

    if(isAnonymous) {
      if (!authPaths.contains(targetPath) &&
          targetPath != '/simple-juror-home' &&
          targetPath != '/juror-qr-scanner' &&
          targetPath != '/juror-voting-procedure') {
        resolver.redirectUntil(const RootRoute());
        return;
      }
      resolver.next();
      return;
    }

    if (authStatus.isAuthenticated && authPaths.contains(targetPath)) {
      resolver.redirectUntil(const RootRoute());
      return;
    }

    if (authStatus.isUnauthenticated && !authPaths.contains(targetPath)) {
      resolver.redirectUntil(const SignInRoute());
      return;
    }

    resolver.next();
  }
}
