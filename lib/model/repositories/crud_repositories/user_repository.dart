import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/user.dart' as my;
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class UserRepository {
  Future<Either<Failure, my.User?>> getUserById({required String id});
}

//* Implementation
class UserRepositoryImpl implements UserRepository {
  final SupabaseClient _supabase;

  UserRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  Session? get currentSession => _supabase.auth.currentSession;

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
}
