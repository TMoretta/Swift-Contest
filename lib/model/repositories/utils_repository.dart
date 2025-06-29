import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class UtilsRepository {
  Future<Either<Failure, String>> genUniqueToken({
    required String tableName,
    required String columnName,
    required int length,
  });
}

//* Implementation
class UtilsRepositoryImpl implements UtilsRepository {
  final SupabaseClient _supabase;

  UtilsRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, String>> genUniqueToken({
    required String tableName,
    required String columnName,
    required int length,
  }) async {
    try {
      final String res = await _supabase.rpc('gen_unique_token', params: {
        'p_table_name': tableName,
        'p_column_name': columnName,
        'p_length': length,
      });
      return right(res);
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
