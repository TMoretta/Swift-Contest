import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/entities/account.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class AccountDao {
  Future<Either<Failure, Account>> updateCurrent({required UserAttributes userAttributes});

  Future<Either<Failure, Account>> getCurrent();

  Future<Either<Failure, Account?>> getNullableCurrent();
}

class AccountDaoImpl implements AccountDao {
  final SupabaseClient _supabase;

  AccountDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Account>> updateCurrent({required UserAttributes userAttributes}) async {
    try {
      final res = await _supabase.auth.updateUser(userAttributes);
      if (res.user == null) {
        return Either.left(Failure());
      }
      return Either.right(Account.fromJson(res.user!.toJson()));
    } on SocketException {
      return Either.left(Failure('Network error'));
    } on PostgrestException catch (e) {
      return Either.left(Failure(e.message));
    } catch (e) {
      return Either.left(Failure());
    }
  }

  @override
  Future<Either<Failure, Account>> getCurrent() async {
    try {
      final User? user = _supabase.auth.currentSession?.user;
      if (user == null) {
        return Either.left(Failure());
      }
      return right(Account.fromJson(user.toJson()));
    } on SocketException {
      return Either.left(Failure('Network error'));
    } on PostgrestException catch (e) {
      return Either.left(Failure(e.message));
    } catch (e) {
      return Either.left(Failure());
    }
  }

  @override
  Future<Either<Failure, Account?>> getNullableCurrent() async {
    try {
      final User? user = _supabase.auth.currentSession?.user;
      return right((user != null) ? Account.fromJson(user.toJson()) : null);
    } on SocketException {
      return Either.left(Failure('Network error'));
    } on PostgrestException catch (e) {
      return Either.left(Failure(e.message));
    } catch (e) {
      return Either.left(Failure());
    }
  }
}
