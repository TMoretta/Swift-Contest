import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/juration.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class JurationRepository {
  Future<Either<Failure, Juration>> createJuration({required Juration juration});

  Future<Either<Failure, Juration>> updateJuration({required Juration juration});

  Future<Either<Failure, Juration>> deleteJurationById({required String id});

  Future<Either<Failure, Juration?>> getJurationById({required String id});

  Future<Either<Failure, Juration?>> getJurationByContestIdAndJurorId({
    required String contestId,
    required String jurorId,
  });

  Future<Either<Failure, List<Juration>>> getJurationsByContestId({required String contestId});

  Future<Either<Failure, List<Juration>>> getJurationsByJurorId({required String jurorId});
}

//* Implementation
class JurationRepositoryImpl implements JurationRepository {
  final SupabaseClient _supabase;

  JurationRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, Juration>> createJuration({required Juration juration}) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc(
        'create_juration',
        params: {'p_juration': juration.toJson()},
      );
      return right(Juration.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Juration>> updateJuration({
    required Juration juration,
  }) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc(
        'update_juration',
        params: {'p_juration': juration.toJson()},
      );
      return right(Juration.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Juration>> deleteJurationById({
    required String id,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_juration_by_id', params: {'p_id': id});
      return right(Juration.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Juration?>> getJurationById({
    required String id,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
        'get_juration_by_id',
        params: {'p_id': id},
      );
      if (res.isEmpty) {
        return right(null);
      }
      return right(Juration.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Juration?>> getJurationByContestIdAndJurorId({
    required String contestId,
    required String jurorId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
        'get_juration_by_contest_id_and_juror_id',
        params: {'p_contest_id': contestId, 'p_juror_id': jurorId},
      );
      if (res.isEmpty) {
        return right(null);
      }
      return right(Juration.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Juration>>> getJurationsByContestId({
    required String contestId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
        'get_jurations_by_contest_id',
        params: {'p_contest_id': contestId},
      );
      return right(res.map((e) => Juration.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Juration>>> getJurationsByJurorId({
    required String jurorId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
        'get_jurations_by_juror_id',
        params: {'p_juror_id': jurorId},
      );
      return right(res.map((e) => Juration.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
