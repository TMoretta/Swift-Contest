import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/user/user.dart' as my;
import 'package:swift_contest/model/services/user_service.dart';
import 'package:swift_contest/viewmodel/repositories/user_repository.dart';

part 'app_auth_event.dart';

part 'app_auth_state.dart';

class AppAuthBloc extends Bloc<AppAuthEvent, AppAuthState> {
  final UserRepository _userRepository;

  AppAuthBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(AppAuthInitial()) {
    on<AppAuthChanged>(_appAuthChanged);
    on<AppAuthSplashPageDelay>(_splashPageDelay);
    _userRepository.appAuthChanges.listen((appAuthChange) {
      add(AppAuthChanged(appAuthChange: appAuthChange));
    });
  }

  void _appAuthChanged(
    AppAuthChanged event,
    Emitter<AppAuthState> emit,
  ) async {
    final AuthChangeEvent changeEvent = event.appAuthChange.event;
    final Session? session = event.appAuthChange.session;

    switch (changeEvent) {
      case AuthChangeEvent.initialSession:
        if (session == null) {
          emit(AppAuthUnauthenticated());
          break;
        }
        final user = my.User(id: session.user.id, email: session.user.email!);
        emit(AppAuthAuthenticated(user: user));
        break;
      case AuthChangeEvent.signedIn:
        if (session == null) {
          emit(AppAuthUnauthenticated());
          break;
        }
        final user = my.User(id: session.user.id, email: session.user.email!);
        emit(AppAuthAuthenticated(user: user));
        break;
      case AuthChangeEvent.signedOut:
        emit(AppAuthUnauthenticated());
        break;
      default:
        break;
    }
  }

  Future<void> _splashPageDelay(
      AppAuthSplashPageDelay event,
    Emitter<AppAuthState> emit,
  ) async {
    final originalState = state;
    emit(AppAuthInitial());
    await Future.delayed(Duration(seconds: 3));
    emit(originalState);
  }
}
