import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/bundles/user_auth_bundle.dart';
import 'package:swift_contest/model/data_models/message.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/user.dart' as my;
import 'package:swift_contest/model/enums/app_theme.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserAuthBundle?>> getCurrentUserAuthBundle();

  Future<Either<Failure, my.User?>> getCurrentUser();

  Future<Either<Failure, Profile?>> getCurrentProfile();

  Future<Either<Failure, List<Message>>> getCurrentProfileMessages();

  Future<Either<Failure, Message>> markMessageAsRead({required String messageId});

  Future<Either<Failure, Unit>> deleteMessage({required String messageId});

  Future<Either<Failure, Unit>> deleteAllProfileMessages({required String profileId});

  Future<Either<Failure, Profile>> updateProfileFullName({required String fullName});

  Future<Either<Failure, Profile>> updateProfilePrefRole({required ContestRole prefRole});

  Future<Either<Failure, Unit>> deleteCurrentAccount();

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

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  Session? get currentSession => _supabase.auth.currentSession;

  @override
  Future<Either<Failure, UserAuthBundle?>> getCurrentUserAuthBundle() async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('get_user_auth_bundle', params: {'p_user_id': currentSession?.user.id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(UserAuthBundle.fromRpcJson(res.first));
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, my.User?>> getCurrentUser() async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_user', params: {'p_user_id': currentSession?.user.id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(my.User.fromJson(res.first));
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Profile?>> getCurrentProfile() async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_profile', params: {'p_user_id': currentSession?.user.id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(Profile.fromJson(res.first));
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getCurrentProfileMessages() async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('get_profile_messages', params: {'p_user_id': currentSession?.user.id});
      return right(res.map((e) => Message.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Message>> markMessageAsRead({required String messageId}) async {
    try {
      final Map<String,dynamic> res = await _supabase.rpc('mark_message_as_read', params: {'p_message_id': messageId});
      return right(Message.fromJson(res));
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage({required String messageId}) async {
    try {
      await _supabase.rpc('delete_message', params: {'p_message_id': messageId});
      return right(unit);
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllProfileMessages({required String profileId}) async {
    try {
      await _supabase.rpc('delete_all_profile_messages', params: {'p_profile_id': profileId});
      return right(unit);
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfileFullName({required String fullName}) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc('update_profile_full_name', params: {
        'p_user_id': currentSession?.user.id,
        'p_full_name': fullName,
      });
      return right(Profile.fromJson(res));
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfilePrefRole({
    required ContestRole prefRole,
  }) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc('update_profile_pref_role', params: {
        'p_user_id': currentSession?.user.id,
        'p_pref_role': prefRole.name,
      });
      return right(Profile.fromJson(res));
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCurrentAccount() async {
    try {
      await _supabase.rpc('delete_account', params: {'p_user_id': currentSession?.user.id});
      _supabase.auth.signOut(scope: SignOutScope.global);
      return right(unit);
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on AuthException catch (e) {
      return left(_authExceptionToRepositoryFailure(e));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signInWithEmail({required String email}) async {
    try {
      await _supabase.auth.signInWithOtp(email: email, shouldCreateUser: false);
      return right(unit);
    } on SocketException {
      return left(Failure(message: 'Network error'));
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
      final bool res =
          await _supabase.rpc('user_exists', params: {'p_email': email});
      if (res) {
        return left(Failure(message: 'An account with this email already exists. Sign in instead'));
      }
      await _supabase.auth.signInWithOtp(
        shouldCreateUser: true,
        email: email,
        data: {
          'full_name': fullName,
        },
      );
      return right(unit);
    } on SocketException {
      return left(Failure(message: 'Network error'));
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
    } on SocketException {
      return left(Failure(message: 'Network error'));
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
    } on SocketException {
      return left(Failure(message: 'Network error'));
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
    } on SocketException {
      return left(Failure(message: 'Network error'));
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
          'full_name': fullName,
        },
      );
      final user = response.user;
      if (user == null) {
        return left(Failure(message: 'No valid session found'));
      }
      return right(my.User.fromJson(user.toJson()));
    } on SocketException {
      return left(Failure(message: 'Network error'));
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
