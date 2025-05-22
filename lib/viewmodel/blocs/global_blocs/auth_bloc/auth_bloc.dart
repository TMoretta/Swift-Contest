import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/model/enums/app_theme.dart';
import 'package:swift_contest/viewmodel/enums/auth_status.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/user_repository.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository _userRepository;
  final ProfileRepository _profileRepository;

  AuthBloc({
    required UserRepository userRepository,
    required ProfileRepository profileRepository,
  })  : _userRepository = userRepository,
        _profileRepository = profileRepository,
        super(AuthState(blocStatus: BlocStatus.initial, authStatus: AuthStatus.initial)) {
    on<AuthInit>(_init);
    on<AuthInitWithDelay>(_initWithDelay);
    on<AuthSignInWithEmail>(_signInWithEmail);
    on<AuthSignUpWithEmail>(_signUpWithEmail);
    on<AuthSignInVerifyOtp>(_signInVerifyOtp);
    on<AuthSignUpVerifyOtp>(_signUpVerifyOtp);
    on<AuthSignOut>(_signOut);
    on<AuthEditFullName>(_editFullName);
    on<AuthEditPrefTheme>(_editPrefTheme);
    on<AuthSignInWithEmailAndPassword>(_signInWithEmailAndPassword);
    on<AuthSignUpWithEmailAndPassword>(_signUpWithEmailAndPassword);
    // on<AuthStatusChanged>(_statusChanged);
    // _userRepository.authChanges.listen((authChange) {
    //   add(AuthStatusChanged(authChanged: authChange));
    // },);
  }

  //* Init the state
  FutureOr<void> _init(
    AuthInit event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(blocStatus: BlocStatus.loading, authStatus: AuthStatus.initial));

    late final User user;
    final eitherUser = _userRepository.getCurrentUser();
    eitherUser.fold(
      (failure) => emit(state.copyWith(
        blocStatus: BlocStatus.failure,
        authStatus: AuthStatus.unauthenticated,
        message: failure.message,
      )),
      (success) => user = success,
    );
    if (eitherUser.isLeft()) {
      return;
    }

    late final Profile profile;
    final eitherProfile = await _profileRepository.getCurrentProfile();
    eitherProfile.fold(
      (failure) => emit(state.copyWith(
        blocStatus: BlocStatus.failure,
        authStatus: AuthStatus.authenticated,
        user: user,
        message: failure.message,
      )),
      (success) => profile = success,
    );
    if (eitherProfile.isLeft()) {
      return;
    }

    emit(state.copyWith(
      blocStatus: BlocStatus.success,
      authStatus: AuthStatus.authenticated,
      user: user,
      profile: profile,
    ));
  }

  //* Init the state with a delay (for the splash page)
  Future<void> _initWithDelay(
    AuthInitWithDelay event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(blocStatus: BlocStatus.loading, authStatus: AuthStatus.initial));
    await Future.delayed(Duration(seconds: event.delay));
    add(AuthInit());
  }

  //* Sign in with email
  FutureOr<void> _signInWithEmail(
    AuthSignInWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(blocStatus: BlocStatus.loading, authStatus: AuthStatus.initial));

    final eitherSignIn = await _userRepository.signInWithEmail(email: event.email);
    eitherSignIn.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(blocStatus: BlocStatus.success)),
    );
  }

  //* Sign up with email
  FutureOr<void> _signUpWithEmail(
    AuthSignUpWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(blocStatus: BlocStatus.loading, authStatus: AuthStatus.initial));

    final eitherSignUp =
        await _userRepository.signUpWithEmail(email: event.email, fullName: event.fullName);
    eitherSignUp.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(blocStatus: BlocStatus.success)),
    );
  }

  //* Verify the otp for the sign in
  FutureOr<void> _signInVerifyOtp(
    AuthSignInVerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(blocStatus: BlocStatus.loading, authStatus: AuthStatus.initial));

    late final User user;
    final eitherVerify = await _userRepository.signInVerifyOtp(email: event.email, otp: event.otp);
    eitherVerify.fold(
      (failure) => emit(
          state.copyWith(blocStatus: BlocStatus.failure, authStatus: AuthStatus.unauthenticated)),
      (success) => user = success,
    );
    if (eitherVerify.isLeft()) {
      return;
    }

    //* Obtaining the profile of the user
    late final Profile profile;
    final eitherProfile = await _profileRepository.getCurrentProfile();
    eitherProfile.fold(
      //* In case of failure the blocStatus will be failure, but the authStatus will be authenticated
      (failure) => emit(state.copyWith(
        blocStatus: BlocStatus.failure,
        authStatus: AuthStatus.authenticated,
        user: user,
        message: failure.message,
      )),
      //* In case of success assign the user and the profile
      (success) => profile = success,
    );

    emit(state.copyWith(
        blocStatus: BlocStatus.success,
        authStatus: AuthStatus.authenticated,
        user: user,
        profile: profile));
  }

  //* Verify the otp for the sign in
  FutureOr<void> _signUpVerifyOtp(
    AuthSignUpVerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(blocStatus: BlocStatus.loading, authStatus: AuthStatus.initial));

    late final User user;
    final eitherVerify = await _userRepository.signUpVerifyOtp(email: event.email, otp: event.otp);
    eitherVerify.fold(
      (failure) => emit(
          state.copyWith(blocStatus: BlocStatus.failure, authStatus: AuthStatus.unauthenticated)),
      (success) => user = success,
    );
    if (eitherVerify.isLeft()) {
      return;
    }

    //* Obtaining the profile of the user
    late final Profile profile;
    final eitherProfile = await _profileRepository.getCurrentProfile();
    eitherProfile.fold(
      //* In case of failure the blocStatus will be failure, but the authStatus will be authenticated
      (failure) => emit(state.copyWith(
        blocStatus: BlocStatus.failure,
        authStatus: AuthStatus.authenticated,
        user: user,
        message: failure.message,
      )),
      //* In case of success assign the user and the profile
      (success) => profile = success,
    );

    emit(state.copyWith(
        blocStatus: BlocStatus.success,
        authStatus: AuthStatus.authenticated,
        user: user,
        profile: profile));
  }

  //* Sign out
  FutureOr<void> _signOut(
    AuthSignOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading));

    //* Check if the user is already signed out
    if (state.authStatus == AuthStatus.unauthenticated) {
      emit(state.copyWith(blocStatus: BlocStatus.failure, message: 'You are already signed out'));
      return;
    }

    final eitherSignOut = await _userRepository.signOut();
    eitherSignOut.fold(
      (failure) => emit(state.copyWith(
        blocStatus: BlocStatus.failure,
        authStatus: AuthStatus.authenticated,
        message: failure.message,
      )),
      (success) => emit(AuthState(
        blocStatus: BlocStatus.success,
        authStatus: AuthStatus.unauthenticated,
      )),
    );
  }

  //* Edit the full name
  FutureOr<void> _editFullName(
    AuthEditFullName event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading));

    final eitherEditFullName = await _profileRepository.updateProfile(profile: state.profile!.copyWith(fullName: event.fullName));
    eitherEditFullName.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(blocStatus: BlocStatus.success, profile: success)),
    );
  }

  FutureOr<void> _editPrefTheme(
    AuthEditPrefTheme event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(blocStatus: BlocStatus.loading));

    final eitherEditPrefTheme = await _profileRepository.updateProfile(profile: state.profile!.copyWith(prefTheme: event.prefTheme));
    eitherEditPrefTheme.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(blocStatus: BlocStatus.success, profile: success)),
    );
  }

  //* Sign in with email and password
  FutureOr<void> _signInWithEmailAndPassword(
    AuthSignInWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    late User user;
    final eitherSignIn = await _userRepository.signInWithEmailAndPassword(
        email: event.email, password: event.password);
    eitherSignIn.fold(
      (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
      (success) => user = success,
    );

    //* Obtaining the profile of the user
    late final Profile profile;
    final eitherProfile = await _profileRepository.getCurrentProfile();
    eitherProfile.fold(
      //* In case of failure the blocStatus will be failure, but the authStatus will be authenticated
          (failure) => emit(state.copyWith(
        blocStatus: BlocStatus.failure,
        authStatus: AuthStatus.authenticated,
        user: user,
        message: failure.message,
      )),
      //* In case of success assign the user and the profile
          (success) => profile = success,
    );

    emit(state.copyWith(
        blocStatus: BlocStatus.success,
        authStatus: AuthStatus.authenticated,
        user: user,
        profile: profile));
  }

  //* Sign up with email and password
  FutureOr<void> _signUpWithEmailAndPassword(
    AuthSignUpWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(blocStatus: BlocStatus.loading, authStatus: AuthStatus.initial));

    final eitherSignUp =
    await _userRepository.signUpWithEmailAndPassword(email: event.email, password: event.password, fullName: event.fullName);
    eitherSignUp.fold(
          (failure) => emit(state.copyWith(blocStatus: BlocStatus.failure, message: failure.message)),
          (success) => emit(state.copyWith(blocStatus: BlocStatus.success)),
    );
  }
}

// Auth changes listener
// void _authChanged(
//   AuthChanged event,
//   Emitter<AuthState> emit,
// ) async {
//   final AuthChangeEvent changeEvent = event.authChange.event;
//   final Session? session = event.authChange.session;
//
//   switch (changeEvent) {
//     case AuthChangeEvent.signedIn:
//       if (session == null) {
//         emit(AuthState(status: AuthStatus.unauthenticated));
//         break;
//       }
//       final user = my.User(id: session.user.id, email: session.user.email!);
//       emit(AuthState(status: AuthStatus.authenticated, user: user));
//       break;
//     case AuthChangeEvent.signedOut:
//       // emit(AuthState(status: AuthStatus.unauthenticated));
//       break;
//     default:
//       break;
//   }
// }
