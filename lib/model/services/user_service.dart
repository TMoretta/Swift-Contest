import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/user/user.dart' as my;
import 'package:swift_contest/utils/exceptions/custom_exception.dart';

class AppAuthChange {
  final AuthChangeEvent event;
  final Session? session;

  AppAuthChange({required this.event, required this.session});
}

//* Interface
abstract interface class UserService {
  Session? get currentSession;

  Stream<AppAuthChange> get appAuthChanges;

  my.User getCurrentUser();

  Future<my.User> getUserById({required String id});

  Future<my.User> signInWithEmailAndPassword({required String email, required String password});

  Future<my.User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<Unit> signOut();
}

//* Implementation
class UserServiceImpl implements UserService {
  final SupabaseClient _supabase;

  UserServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Session? get currentSession => _supabase.auth.currentSession;

  @override
  Stream<AppAuthChange> get appAuthChanges => _supabase.auth.onAuthStateChange
      .map((data) => AppAuthChange(event: data.event, session: data.session));

  @override
  my.User getCurrentUser() {
    try {
      final session = currentSession;
      if (session != null) {
        return my.User.fromJson(session.user.toJson());
      }
      throw CustomException(message: 'No valid session');
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<my.User> getUserById({required String id}) async {
    try {
      final Map<String, dynamic> userMap =
          await _supabase.rpc('get_user_by_id', params: {'p_id': id});
      return my.User.fromJson(userMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<my.User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      final session = response.session;
      if (session != null) {
        return my.User.fromJson(session.user.toJson());
      }
      throw CustomException(message: 'Session is null');
    } on AuthException catch (e) {
      throw (_authExceptionToCustomException(e));
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<my.User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
        },
      );
      final user = response.user;
      if (user != null) {
        return my.User.fromJson(user.toJson());
      }
      throw CustomException(message: 'User is null');
    } on AuthException catch (e) {
      throw (_authExceptionToCustomException(e));
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Unit> signOut() async {
    try {
      await _supabase.auth.signOut();
      return unit;
    } on AuthException catch (e) {
      throw (_authExceptionToCustomException(e));
    } on Exception catch (e) {
      throw CustomException(message: e.toString());
    }
  }
}

//* Map the supabase auth exceptions to my custom server exception
CustomException _authExceptionToCustomException(AuthException exception) {
  if (exception.code != null) {
    switch (exception.code) {
      //* Supabase exceptions
      case 'email_address_invalid':
        return CustomException(message: exception.message);
      case 'email_exists':
        return CustomException(message: exception.message);
      case 'email_not_confirmed':
        return CustomException(message: exception.message);
      case 'invalid_credentials':
        return CustomException(message: exception.message);
      case 'over_request_rate_limit':
        return CustomException(message: exception.message);
      case 'reauthentication_needed':
        return CustomException(message: exception.message);
      case 'request_timeout':
        return CustomException(message: exception.message);
      case 'session_expired':
        return CustomException(message: exception.message);
      case 'session_not_found':
        return CustomException(message: exception.message);
      case 'unexpected_failure':
        return CustomException(message: exception.message);
      case 'user_already_exists':
        return CustomException(message: exception.message);
      case 'user_banned':
        return CustomException(message: exception.message);
      case 'user_not_found':
        return CustomException(message: exception.message);
      case 'validation_failed':
        return CustomException(message: exception.message);
      case 'weak_password':
        return CustomException(message: exception.message);
      default:
        return CustomException(message: 'An error occurred. Please try again.');
    }
  } else {
    return CustomException(message: 'An error occurred. Please try again.');
  }
}
