import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/user.dart' as my;
import 'package:swift_contest/model/enums/app_theme.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

class AuthChange {
  final AuthChangeEvent event;
  final Session? session;

  AuthChange({required this.event, required this.session});
}

//* Interface
abstract interface class UserService {
  Stream<AuthChange> get authChanges;

  my.User getCurrentUser();

  Future<my.User> getUserById({required String id});

  Future<my.User> signInWithEmailAndPassword({required String email, required String password});

  Future<my.User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Unit> signOut();
}

//* Implementation
class UserServiceImpl implements UserService {
  final SupabaseClient _supabase;

  UserServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  Session? get currentSession => _supabase.auth.currentSession;

  @override
  Stream<AuthChange> get authChanges => _supabase.auth.onAuthStateChange
      .map((data) => AuthChange(event: data.event, session: data.session));

  @override
  my.User getCurrentUser() {
    try {
      final session = currentSession;
      if (session != null) {
        return my.User.fromJson(session.user.toJson());
      }
      throw UnsafeException(message: 'No valid session');
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<my.User> getUserById({required String id}) async {
    try {
      final Map<String, dynamic> userMap =
      await _supabase.rpc('get_user_by_id', params: {'p_id': id});
      return my.User.fromJson(userMap);
    } catch (e) {
      throw UnsafeException(message: e.toString());
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
      throw UnsafeException(message: 'Session is null');
    } on AuthException catch (e) {
      throw (_authExceptionToCustomException(e));
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<my.User> signUpWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'created_at' : DateTime.now().toUtc().toIso8601String(),
          'full_name': fullName,
          'pref_theme': AppTheme.system.name,
          'pref_contest_role': ContestRole.organizer.name,
          'is_deleted' : false,
        },
      );
      final user = response.user;
      if (user != null) {
        return my.User.fromJson(user.toJson());
      }
      throw UnsafeException(message: 'User is null');
    } on AuthException catch (e) {
      throw (_authExceptionToCustomException(e));
    } catch (e) {
      throw UnsafeException(message: e.toString());
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
      throw UnsafeException(message: e.toString());
    }
  }
}

//* Map the supabase auth exceptions to my custom server exception
UnsafeException _authExceptionToCustomException(AuthException exception) {
  if (exception.code != null) {
    switch (exception.code) {
    //* Supabase exceptions
      case 'email_address_invalid':
        return UnsafeException(message: exception.message);
      case 'email_exists':
        return UnsafeException(message: exception.message);
      case 'email_not_confirmed':
        return UnsafeException(message: exception.message);
      case 'invalid_credentials':
        return UnsafeException(message: exception.message);
      case 'over_request_rate_limit':
        return UnsafeException(message: exception.message);
      case 'reauthentication_needed':
        return UnsafeException(message: exception.message);
      case 'request_timeout':
        return UnsafeException(message: exception.message);
      case 'session_expired':
        return UnsafeException(message: exception.message);
      case 'session_not_found':
        return UnsafeException(message: exception.message);
      case 'unexpected_failure':
        return UnsafeException(message: exception.message);
      case 'user_already_exists':
        return UnsafeException(message: exception.message);
      case 'user_banned':
        return UnsafeException(message: exception.message);
      case 'user_not_found':
        return UnsafeException(message: exception.message);
      case 'validation_failed':
        return UnsafeException(message: exception.message);
      case 'weak_password':
        return UnsafeException(message: exception.message);
      default:
        return UnsafeException(message: 'An error occurred. Please try again.');
    }
  } else {
    return UnsafeException(message: 'An error occurred. Please try again.');
  }
}
