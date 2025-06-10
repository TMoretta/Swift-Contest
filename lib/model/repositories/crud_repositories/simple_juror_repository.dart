import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/simple_juror.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class SimpleJurorRepository {
  Future<Either<Failure, SimpleJuror>> createSimpleJuror({required SimpleJuror simpleJuror});

  Future<Either<Failure, SimpleJuror>> updateSimpleJuror({required SimpleJuror simpleJuror});

  Future<Either<Failure, SimpleJuror>> deleteSimpleJurorById({required String id});

  Future<Either<Failure, SimpleJuror?>> getSimpleJurorById({required String id});
}

//* Implementation
class SimpleJurorRepositoryImpl implements SimpleJurorRepository {
  final SupabaseClient _supabase;

  SimpleJurorRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, SimpleJuror>> createSimpleJuror({
    required SimpleJuror simpleJuror,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('create_simple_juror', params: {'p_simple_juror': simpleJuror.toJson()});
      return right(SimpleJuror.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJuror>> updateSimpleJuror({
    required SimpleJuror simpleJuror,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('update_simple_juror', params: {'p_simple_juror': simpleJuror.toJson()});
      return right(SimpleJuror.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJuror>> deleteSimpleJurorById({required String id}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_simple_juror_by_id', params: {'p_id': id});
      return right(SimpleJuror.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJuror?>> getSimpleJurorById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_simple_juror_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(SimpleJuror.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
