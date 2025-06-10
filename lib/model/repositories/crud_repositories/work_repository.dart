import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class WorkRepository {
  Future<Either<Failure, Work>> createWork({required Work work});

  Future<Either<Failure, Work>> updateWork({required Work work});

  Future<Either<Failure, Work>> deleteWorkById({required String id});

  Future<Either<Failure, Work?>> getWorkById({required String id});

  Future<Either<Failure, Work?>> getWorkByParticipationId({required String participationId});
}

//* Implementation
class WorkRepositoryImpl implements WorkRepository {
  final SupabaseClient _supabase;

  WorkRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, Work>> createWork({required Work work}) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc('create_work', params: {'p_work': work.toJson()});
      return right(Work.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Work>> updateWork({required Work work}) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc('update_work', params: {'p_work': work.toJson()});
      return right(Work.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Work>> deleteWorkById({required String id}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_work_by_id', params: {'p_id': id});
      return right(Work.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Work?>> getWorkById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_work_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(Work.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Work?>> getWorkByParticipationId({required String participationId}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('get_work_by_participation_id', params: {'p_participation_id': participationId});
      if (res.isEmpty) {
        return right(null);
      }
      return right(Work.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
