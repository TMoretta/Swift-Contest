// import 'package:auto_route/auto_route.dart';
// import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
// import 'package:swift_contest/viewmodel/types/auth_status.dart';
//
// import 'app_router.gr.dart';
//
// class AuthGuard extends AutoRouteGuard {
//   final AuthBloc authBloc;
//
//   AuthGuard({required this.authBloc});
//
//   @override
//   void onNavigation(NavigationResolver resolver, StackRouter router) {
//     // 1. Prendi lo stato corrente dall'AuthBloc
//     final authState = authBloc.state;
//     // 2. Ricava la rotta di destinazione (il "path")
//     //    AutoRoute ti espone il path di PageRouteInfo in .path
//     final targetPath = resolver.route.path;
//
//     // 3. Se siamo alla root o alla rotta di voting aperta, prosegui senza controlli
//     if (targetPath == '/' || targetPath == '/simple-juror-voting-procedure') {
//       resolver.next();
//       return;
//     }
//
//     // 4. Se NON autenticato e non sto andando su pagine di auth, redirigi al login
//     const authPaths = ['/sign-in', '/sign-up', '/sign-up-verify', '/sign-in-verify'];
//     if (authState.authStatus.isUnauthenticated && !authPaths.contains(targetPath)) {
//       resolver.redirectUntil(const SignInRoute());
//       return;
//     }
//
//     // 5. Se autenticato e sto andando su pagine di auth, rimandami alla home
//     if (authState.authStatus.isAuthenticated && authPaths.contains(targetPath)) {
//       resolver.redirectUntil(const RootRoute());
//       return;
//     }
//
//     // 6. Altrimenti nessuna condizione di guard applicata, prosegui
//     resolver.next();
//   }
// }
