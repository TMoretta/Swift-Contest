import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/juration.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class JurationService {
  Future<Juration> createJuration({required Juration juration});

  Future<Juration> updateJuration({required Juration juration}); // "ById" removed, ID in Juration object

  Future<Unit> deleteJurationById({required String id});

  Future<Juration> getJurationById({required String id});

  Future<Juration> getJurationByContestIdAndJurorId({
    required String contestId,
    required String jurorId,
  });

  Future<List<Juration>> getJurationsByContestId({required String contestId});

  Future<List<Juration>> getJurationsByJurorId({required String jurorId});
}

//* Implementation
class JurationServiceImpl implements JurationService {
  final SupabaseClient _supabase;

  JurationServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Juration> createJuration({required Juration juration}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
        'create_juration',
        params: juration.toRpcJson(),
      );
      if (res.isEmpty) {
        throw SafeException(message: 'Juration creation failed');
      }
      return Juration.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Juration> updateJuration({required Juration juration}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
        'update_juration',
        params: juration.toRpcJson(),
      );

      if (res.isEmpty) {
        throw SafeException(message: 'Juration update failed');
      }
      return Juration.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteJurationById({required String id}) async {
    try {
      await _supabase.rpc('delete_juration_by_id', params: {'p_id': id});
      return unit;
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Juration> getJurationById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
        'get_juration_by_id',
        params: {'p_id': id},
      );
      if (res.isEmpty) {
        throw SafeException(message: 'No juration found');
      }
      return Juration.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Juration> getJurationByContestIdAndJurorId({
    required String contestId,
    required String jurorId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
        'get_juration_by_contest_id_and_juror_id',
        params: {'p_contest_id': contestId, 'p_juror_id': jurorId},
      );
      if (res.isEmpty) {
        throw SafeException(message: 'No juration found');
      }
      return Juration.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Juration>> getJurationsByContestId({required String contestId}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
        'get_jurations_by_contest_id',
        params: {'p_contest_id': contestId},
      );
      return res.map((e) => Juration.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Juration>> getJurationsByJurorId({required String jurorId}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
        'get_jurations_by_juror_id',
        params: {'p_juror_id': jurorId},
      );
      return res.map((e) => Juration.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}