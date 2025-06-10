import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class ContestRepository {
  Future<Either<Failure, Contest>> createContest({required Contest contest});

  Future<Either<Failure, Contest>> updateContest({
    required Contest contest,
  });

  Future<Either<Failure, Contest>> deleteContestById({required String id});

  Future<Either<Failure, List<Contest>>> getAllContests();

  Future<Either<Failure, Contest?>> getContestById({required String id});

  Future<Either<Failure, List<Contest>>> getContestsByOrganizerId({required String organizerId});

  Future<Either<Failure, Contest?>> getContestByToken({required String token});
}

//* Implementation
class ContestRepositoryImpl implements ContestRepository {
  final SupabaseClient _supabase;

  ContestRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, Contest>> createContest({required Contest contest}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('create_contest', params: {'p_contest': contest.toJson()});
      return right(Contest.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Contest>> updateContest({
    required Contest contest,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('update_contest', params: {'p_contest': contest.toJson()});
      return right(Contest.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Contest>> deleteContestById({required String id}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_contest_by_id', params: {'p_id': id});
      return right(Contest.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Contest>>> getAllContests() async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc('get_all_contests');
      return right(res.map((e) => Contest.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Contest?>> getContestById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_contest_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(Contest.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Contest>>> getContestsByOrganizerId({
    required String organizerId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('get_contests_by_organizer_id', params: {'p_organizer_id': organizerId});
      return right(res.map((e) => Contest.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Contest?>> getContestByToken({required String token}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_contest_by_token', params: {'p_token': token});
      if (res.isEmpty) {
        return right(null);
      }
      return right(Contest.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
