// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
// import 'package:swift_contest/viewmodel/enums/auth_status.dart';
//
// class AuthBlocNotifier extends ChangeNotifier {
//   final AuthBloc authBloc;
//   late final StreamSubscription<AuthState> _subscription;
//   late AuthStatus _lastAuthStatus;
//
//   AuthBlocNotifier({required this.authBloc}) {
//     // Initialize with the current authentication status
//     _lastAuthStatus = authBloc.state.authStatus;
//
//     // Listen to AuthBloc state changes
//     _subscription = authBloc.stream.listen((newState) {
//       final newStatus = newState.authStatus;
//       if (newStatus != _lastAuthStatus) {
//         _lastAuthStatus = newStatus;
//         notifyListeners();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
// }
//
// // Ascolta i cambiamenti di stato dell'AuthBloc
// // Assegnato al go router per reindirizzare in base allo stato dell'autenticazione
// // class AppAuthBlocNotifier extends ChangeNotifier {
// //   final AuthBloc authBloc;
// //   late final StreamSubscription _subscription;
// //
// //   AppAuthBlocNotifier({required this.authBloc}) {
// //     _subscription = authBloc.stream.listen((_) => notifyListeners());
// //   }
// //
// //   @override
// //   void dispose() {
// //     _subscription.cancel();
// //     super.dispose();
// //   }
// // }