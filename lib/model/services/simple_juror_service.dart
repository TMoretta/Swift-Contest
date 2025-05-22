import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/simple_juror.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class SimpleJurorService {
  Future<SimpleJuror> createSimpleJuror({required SimpleJuror simpleJuror});

  Future<SimpleJuror> updateSimpleJuror({required SimpleJuror simpleJuror});

  Future<Unit> deleteSimpleJurorById({required String id});

  Future<SimpleJuror> getSimpleJurorById({required String id});
}

//* Implementation
class SimpleJurorServiceImpl implements SimpleJurorService {
  final SupabaseClient _supabase;

  SimpleJurorServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<SimpleJuror> createSimpleJuror(
      {required SimpleJuror simpleJuror}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'create_simple_juror', params: simpleJuror.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'SimpleJuror creation failed');
      }
      return SimpleJuror.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<SimpleJuror> updateSimpleJuror(
      {required SimpleJuror simpleJuror}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'update_simple_juror',
          params: simpleJuror.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'SimpleJuror update failed');
      }
      return SimpleJuror.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteSimpleJurorById({required String id}) async {
    try {
      await _supabase.rpc('delete_simple_juror_by_id', params: {'p_id': id});
      return unit;
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<SimpleJuror> getSimpleJurorById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_simple_juror_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        throw SafeException(message: 'No SimpleJuror found');
      }
      return SimpleJuror.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}