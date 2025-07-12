import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/user.dart' as my;
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class AdminRepository {
  Future<Either<Failure, my.User>> adminSignInWithEmailAndPassword({
    required String email,
    required String password,
  });
}

class AdminRepositoryImpl implements AdminRepository {
  final SupabaseClient _supabase;

  AdminRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, my.User>> adminSignInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      final session = response.session;
      if (session == null) {
        return left(Failure(message: 'No valid session found'));
      }
      final user = my.User.fromRpcJson(session.user.toJson());
      if (!user.isAdmin) {
        await _supabase.auth.signOut();
        return left(Failure(message: 'Invalid credentials'));
      }
      return right(user);
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on AuthException catch (e) {
      return left(_authExceptionToRepositoryFailure(e));
    } catch (e) {
      return left(Failure());
    }
  }
}

//* Map the supabase auth exceptions to my custom server exception
Failure _authExceptionToRepositoryFailure(AuthException exception) {
  if (exception.code != null) {
    switch (exception.code) {
      //* Supabase exceptions
      case 'email_address_invalid':
        return Failure(message: exception.message);
      case 'email_exists':
        return Failure(message: exception.message);
      case 'email_not_confirmed':
        return Failure(message: exception.message);
      case 'invalid_credentials':
        return Failure(message: exception.message);
      case 'over_request_rate_limit':
        return Failure(message: exception.message);
      case 'reauthentication_needed':
        return Failure(message: exception.message);
      case 'request_timeout':
        return Failure(message: exception.message);
      case 'session_expired':
        return Failure(message: exception.message);
      case 'session_not_found':
        return Failure(message: exception.message);
      case 'unexpected_failure':
        return Failure(message: exception.message);
      case 'user_already_exists':
        return Failure(message: exception.message);
      case 'user_banned':
        return Failure(message: exception.message);
      case 'user_not_found':
        return Failure(message: exception.message);
      case 'validation_failed':
        return Failure(message: exception.message);
      case 'weak_password':
        return Failure(message: exception.message);
      case 'otp_disabled':
        return Failure(message: exception.message);
      case 'over_email_send_rate_limit':
        return Failure(message: exception.message);
      case 'otp_expired':
        return Failure(message: exception.message);
      default:
        return Failure();
    }
  } else {
    return Failure();
  }
}
