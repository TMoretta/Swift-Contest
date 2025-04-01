import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/user/user.dart' as my;
import 'package:swift_contest/model/services/user_service.dart';
import 'package:swift_contest/viewmodel/repositories/user_repository.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository _userRepository;

  AuthBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(AuthInitial()) {
    // on<AuthCheckInitialSession>(_checkInitialSession);
    on<AuthChanged>(_authChanged);
    on<AuthCheckInitialSessionWithDelay>(_checkInitialSessionWithDelay);
    // add(AuthCheckInitialSession());
    _userRepository.authChanges.listen((authChange) {
      add(AuthChanged(authChange: authChange));
    });
  }

  // FutureOr<void> _checkInitialSession(
  //   AuthCheckInitialSession event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());
  //   final currentUser = _userRepository.getCurrentUser();
  //   currentUser.fold(
  //     (failure) => emit(AuthUnauthenticated()),
  //     (user) => emit(AuthAuthenticated(user: user)),
  //   );
  // }

  void _authChanged(
    AuthChanged event,
    Emitter<AuthState> emit,
  ) async {
    final AuthChangeEvent changeEvent = event.authChange.event;
    final Session? session = event.authChange.session;

    switch (changeEvent) {
      case AuthChangeEvent.initialSession:
        // if (session == null) {
        //   emit(AuthUnauthenticated());
        //   break;
        // }
        // final user = my.User(id: session.user.id, email: session.user.email!);
        // emit(AuthAuthenticated(user: user));
        break;
      case AuthChangeEvent.signedIn:
        if (session == null) {
          emit(AuthUnauthenticated());
          break;
        }
        final user = my.User(id: session.user.id, email: session.user.email!);
        emit(AuthAuthenticated(user: user));
        break;
      case AuthChangeEvent.signedOut:
        emit(AuthUnauthenticated());
        break;
      case AuthChangeEvent.tokenRefreshed:
        // if (session == null) {
        //   emit(AuthUnauthenticated());
        //   break;
        // }
        // final user = my.User(id: session.user.id, email: session.user.email!);
        // emit(AuthAuthenticated(user: user));
        break;
      default:
        break;
    }
  }

  Future<void> _checkInitialSessionWithDelay(
    AuthCheckInitialSessionWithDelay event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(Duration(seconds: 3));
    final currentUser = _userRepository.getCurrentUser();
    currentUser.fold(
          (failure) => emit(AuthUnauthenticated()),
          (user) => emit(AuthAuthenticated(user: user)),
    );
  }
}
