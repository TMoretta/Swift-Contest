import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class ContestService {
  Future<Contest> createContest({required Contest contest});

  Future<Contest> updateContestById(
      {required String id, required Contest contest,});

  Future<Unit> deleteContestById({required String id});

  Future<List<Contest>> getAllContests();

  Future<Contest> getContestById({required String id});

  Future<List<Contest>> getContestsByOrganizerId({required String organizerId});

  Future<Contest> getContestByToken({required String token});
}

//* Implementation
class ContestServiceImpl implements ContestService {
  final SupabaseClient _supabase;

  ContestServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<Contest> createContest({required Contest contest}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('contests').insert(contest.toJson()).select();
      return Contest.fromJson(results[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Contest> updateContestById({
    required String id,
    required Contest contest,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('contests')
          .update(contest.toJson())
          .eq('id', id)
          .select();
      return Contest.fromJson(results[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteContestById({required String id}) async {
    try {
      await _supabase.from('contests').delete().eq('id', id);
      return unit;
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Contest>> getAllContests() async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('contests').select();
      return results.map((e) => Contest.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Contest> getContestById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('contests').select().eq('id', id);
      return Contest.fromJson(results[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Contest>> getContestsByOrganizerId({
    required String organizerId,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('contests')
          .select()
          .eq('organizer_id', organizerId);
      return results.map((e) => Contest.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Contest> getContestByToken({required String token}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('contests').select().eq('token', token);
      if (results.isEmpty) {
        throw UnsafeException(
            message:
                'Invalid invite credentials'); //TODO: Change this exception to safe
      }
      return Contest.fromJson(results[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
