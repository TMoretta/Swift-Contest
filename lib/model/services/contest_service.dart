import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class ContestService {
  Future<Contest> createContest({required Contest contest});

  Future<Contest> updateContest({
    required Contest contest,
  });

  Future<Unit> deleteContestById({required String id});

  Future<List<Contest>> getAllContests();

  Future<Contest> getContestById({required String id});

  Future<List<Contest>> getContestsByOrganizerId({required String organizerId});

  Future<Contest> getContestByToken({required String token});
}

//* Implementation
class ContestServiceImpl implements ContestService {
  final SupabaseClient _supabase;

  ContestServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Contest> createContest({required Contest contest}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'create_contest', params: contest.toRpcJson());
      if(res.isEmpty) {
        throw SafeException(message: 'Contest creation failed');
      }
      return Contest.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Contest> updateContest({
    required Contest contest,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
      await _supabase.rpc('update_contest',params: contest.toRpcJson());
      if(res.isEmpty) {
        throw SafeException(message: 'Contest update failed');
      }
      return Contest.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteContestById({required String id}) async {
    try {
      await _supabase.rpc('delete_contest_by_id',params: {'p_id':id});
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
      final List<Map<String, dynamic>> res = await _supabase.rpc('get_all_contests');
      return res.map((e) => Contest.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Contest> getContestById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
      await _supabase.rpc('get_contest_by_id',params: {'p_id':id});
      if(res.isEmpty) {
        throw SafeException(message: 'No contest found');
      }
      return Contest.fromJson(res[0]);
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
      final List<Map<String, dynamic>> res =
      await _supabase.rpc('get_contests_by_organizer_id',params: {'p_organizer_id':organizerId});
      return res.map((e) => Contest.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Contest> getContestByToken({required String token}) async {
    try {
      final List<Map<String, dynamic>> res =
      await _supabase.rpc('get_contest_by_token',params: {'p_token':token});
      if (res.isEmpty) {
        throw SafeException(message: 'No contest found');
      }
      return Contest.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
