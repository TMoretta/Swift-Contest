import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class WorkService {
  Future<Work> createWork({required Work work});

  Future<Work> updateWorkById({required String id, required Work work});

  Future<Unit> deleteWorkById({required String id});

  Future<Work> getWorkById({required String id});

  Future<Work> getWorkByParticipationId({required String participationId});
}

//* Implementation
class WorkServiceImpl implements WorkService {
  final SupabaseClient _supabase;

  WorkServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<Work> createWork({required Work work}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('works').insert(work.toJson()).select();
      return Work.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Work> updateWorkById({required String id, required Work work}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('works')
          .update(work.toJson())
          .eq('id', id)
          .select();
      return Work.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteWorkById({required String id}) async {
    try {
      await _supabase.from('works').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Work> getWorkById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('works').select().eq('id', id);
      return Work.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Work> getWorkByParticipationId({
    required String participationId,
  }) async {
    try {
      final List<Map<String, dynamic>> results =
      await _supabase.from('works').select().eq('participation_id', participationId);
      return Work.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
