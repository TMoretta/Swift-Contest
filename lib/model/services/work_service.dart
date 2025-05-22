import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class WorkService {
  Future<Work> createWork({required Work work});

  Future<Work> updateWork({required Work work});

  Future<Unit> deleteWorkById({required String id});

  Future<Work> getWorkById({required String id});

  Future<Work> getWorkByParticipationId({required String participationId});
}

//* Implementation
class WorkServiceImpl implements WorkService {
  final SupabaseClient _supabase;

  WorkServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Work> createWork({required Work work}) async {
    try {
      final List<Map<String, dynamic>> res =
      await _supabase.rpc('create_work', params: work.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'Work creation failed');
      }
      return Work.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Work> updateWork({required Work work}) async {
    try {
      final List<Map<String, dynamic>> res =
      await _supabase.rpc('update_work', params: work.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'Work update failed');
      }
      return Work.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteWorkById({required String id}) async {
    try {
      await _supabase.rpc('delete_work_by_id', params: {'p_id': id});
      return unit;
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Work> getWorkById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
      await _supabase.rpc('get_work_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        throw SafeException(message: 'No Work found');
      }
      return Work.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Work> getWorkByParticipationId({required String participationId}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('get_work_by_participation_id', params: {'p_participation_id': participationId});
      if (res.isEmpty) {
        throw SafeException(message: 'No Work found');
      }
      return Work.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}