import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/juration.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class JurationService {
  Future<Juration> createJuration({required Juration juration});

  Future<Juration> updateJurationById({required String id, required Juration juration});

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
      final List<Map<String, dynamic>> results =
          await _supabase.from('jurations').insert(juration.toJson()).select();
      return Juration.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Juration> updateJurationById({required String id, required Juration juration}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('jurations')
          .update(juration.toJson())
          .eq('id', id)
          .select();
      return Juration.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteJurationById({required String id}) async {
    try {
      await _supabase.from('jurations').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Juration> getJurationById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('jurations').select().eq('id', id);
      return Juration.fromJson(results[0]);
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
      final List<Map<String, dynamic>> results = await _supabase
          .from('jurations')
          .select()
          .eq('contest_id', contestId)
          .eq('juror_id', jurorId);
      return Juration.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Juration>> getJurationsByContestId({required String contestId}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('jurations').select().eq('contest_id', contestId);
      return results.map((e) => Juration.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Juration>> getJurationsByJurorId({required String jurorId}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('jurations').select().eq('juror_id', jurorId);
      return results.map((e) => Juration.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
