import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/simple_juror.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class SimpleJurorService {
  Future<SimpleJuror> createSimpleJuror({required SimpleJuror simpleJuror});

  Future<SimpleJuror> updateSimpleJurorById(
      {required String id, required SimpleJuror simpleJuror});

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
      final List<Map<String, dynamic>> results = await _supabase
          .from('simple_jurors')
          .insert(simpleJuror.toJson())
          .select();
      return SimpleJuror.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<SimpleJuror> updateSimpleJurorById(
      {required String id, required SimpleJuror simpleJuror}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('simple_jurors')
          .update(simpleJuror.toJson())
          .eq('id', id)
          .select();
      return SimpleJuror.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteSimpleJurorById({required String id}) async {
    try {
      await _supabase.from('simple_jurors').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<SimpleJuror> getSimpleJurorById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('simple_jurors').select().eq('id', id);
      return SimpleJuror.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
