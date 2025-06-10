import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_session_simple_juror.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class VotingSessionSimpleJurorRepository {
  Future<Either<Failure, VotingSessionSimpleJuror>> createVotingSessionSimpleJuror({
    required VotingSessionSimpleJuror votingSessionSimpleJuror,
  });

  Future<Either<Failure, VotingSessionSimpleJuror>> updateVotingSessionSimpleJuror({
    required VotingSessionSimpleJuror votingSessionSimpleJuror,
  });

  Future<Either<Failure, VotingSessionSimpleJuror>> deleteVotingSessionSimpleJurorById({
    required String id,
  });

  Future<Either<Failure, VotingSessionSimpleJuror?>> getVotingSessionSimpleJurorById({
    required String id,
  });

  Future<Either<Failure, List<VotingSessionSimpleJuror>>>
      getVotingSessionSimpleJurorsByVotingSessionId({
    required String votingSessionId,
  });
}

//* Implementation
class VotingSessionSimpleJurorRepositoryImpl implements VotingSessionSimpleJurorRepository {
  final SupabaseClient _supabase;

  VotingSessionSimpleJurorRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<Either<Failure, VotingSessionSimpleJuror>> createVotingSessionSimpleJuror({
    required VotingSessionSimpleJuror votingSessionSimpleJuror,
  }) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc('create_voting_session_simple_juror',
          params: {'p_voting_session_simple_juror': votingSessionSimpleJuror.toJson()});
      return right(VotingSessionSimpleJuror.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionSimpleJuror>> updateVotingSessionSimpleJuror({
    required VotingSessionSimpleJuror votingSessionSimpleJuror,
  }) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc('update_voting_session_simple_juror',
          params: {'p_voting_session_simple_juror': votingSessionSimpleJuror.toJson()});
      return right(VotingSessionSimpleJuror.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionSimpleJuror>> deleteVotingSessionSimpleJurorById({
    required String id,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_voting_session_simple_juror_by_id', params: {'p_id': id});
      return right(VotingSessionSimpleJuror.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionSimpleJuror?>> getVotingSessionSimpleJurorById({
    required String id,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_voting_session_simple_juror_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(VotingSessionSimpleJuror.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<VotingSessionSimpleJuror>>>
      getVotingSessionSimpleJurorsByVotingSessionId({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_simple_jurors_by_voting_session_id',
          params: {'p_voting_session_id': votingSessionId});
      return right(res.map((e) => VotingSessionSimpleJuror.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
