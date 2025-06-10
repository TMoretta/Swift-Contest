import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/user.dart' as my;
import 'package:swift_contest/model/enums/app_theme.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/failures/failures.dart';
import 'package:swift_contest/utils/functions/now.dart';

//* Interface
abstract interface class UserRepository {
  Either<Failure, my.User?> getCurrentUser();

  Future<Either<Failure, my.User?>> getUserById({required String id});

  Future<Either<Failure, Unit>> signInWithEmail({required String email});

  Future<Either<Failure, Unit>> signUpWithEmail({required String email, required String fullName});

  Future<Either<Failure, my.User>> signInVerifyOtp({required String email, required String otp});

  Future<Either<Failure, my.User>> signUpVerifyOtp({required String email, required String otp});

  Future<Either<Failure, my.User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, my.User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Either<Failure, Unit>> signOut();
}

//* Implementation
class UserRepositoryImpl implements UserRepository {
  final SupabaseClient _supabase;

  UserRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  Session? get currentSession => _supabase.auth.currentSession;

  @override
  Either<Failure, my.User?> getCurrentUser() {
    try {
      final session = currentSession;
      if (session == null) {
        return right(null);
      }
      return right(my.User.fromJson(session.user.toJson()));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, my.User?>> getUserById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_user_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(my.User.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signInWithEmail({required String email}) async {
    try {
      await _supabase.auth.signInWithOtp(email: email, shouldCreateUser: false);
      return right(unit);
    } on AuthException catch (e) {
      return left(_authExceptionToRepositoryFailure(e));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signUpWithEmail({
    required String email,
    required String fullName,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_user_by_email', params: {'p_email': email});
      if (res.isNotEmpty) {
        return left(Failure(message: 'User already exists. Sign in instead'));
      }
      await _supabase.auth.signInWithOtp(
        shouldCreateUser: true,
        email: email,
        data: {
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'full_name': fullName,
          'pref_theme': AppTheme.system.name,
          'pref_contest_role': ContestRole.organizer.name,
          'is_deleted': false,
        },
      );
      return right(unit);
    } on AuthException catch (e) {
      return left(_authExceptionToRepositoryFailure(e));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, my.User>> signInVerifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: otp,
      );
      final session = response.session;
      if (session == null) {
        return left(Failure(message: 'No valid session found'));
      }
      return right(my.User.fromJson(session.user.toJson()));
    } on AuthException catch (e) {
      return left(_authExceptionToRepositoryFailure(e));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, my.User>> signUpVerifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: otp,
      );
      final session = response.session;
      if (session == null) {
        return left(Failure(message: 'No valid session found'));
      }
      return right(my.User.fromJson(session.user.toJson()));
    } on AuthException catch (e) {
      return left(_authExceptionToRepositoryFailure(e));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, my.User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      final session = response.session;
      if (session == null) {
        return left(Failure(message: 'No valid session found'));
      }
      return right(my.User.fromJson(session.user.toJson()));
    } on AuthException catch (e) {
      return left(_authExceptionToRepositoryFailure(e));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, my.User>> signUpWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'created_at': now().toUtc().toIso8601String(),
          'full_name': fullName,
          'pref_theme': AppTheme.system.name,
          'pref_contest_role': ContestRole.organizer.name,
          'is_deleted': false,
        },
      );
      final user = response.user;
      if (user == null) {
        return left(Failure(message: 'No valid session found'));
      }
      return right(my.User.fromJson(user.toJson()));
    } on AuthException catch (e) {
      return left(_authExceptionToRepositoryFailure(e));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return right(unit);
    } on AuthException catch (e) {
      throw (_authExceptionToRepositoryFailure(e));
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
      default:
        return Failure();
    }
  } else {
    return Failure();
  }
}
