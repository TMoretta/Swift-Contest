import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_session_exclusion.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class VotingSessionExclusionRepository {
  Future<Either<Failure, VotingSessionExclusion>> createVotingSessionExclusion({
    required VotingSessionExclusion votingSessionExclusion,
  });

  Future<Either<Failure, VotingSessionExclusion>> updateVotingSessionExclusion({
    required VotingSessionExclusion votingSessionExclusion,
  });

  Future<Either<Failure, VotingSessionExclusion>> deleteVotingSessionExclusionById({
    required String id,
  });

  Future<Either<Failure, VotingSessionExclusion?>> getVotingSessionExclusionById({
    required String id,
  });

  Future<Either<Failure, List<VotingSessionExclusion>>>
      getVotingSessionExclusionsByVotingSessionJurationId({
    required String votingSessionJurationId,
  });
}

class VotingSessionExclusionRepositoryImpl implements VotingSessionExclusionRepository {
  final SupabaseClient _supabase;

  VotingSessionExclusionRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<Either<Failure, VotingSessionExclusion>> createVotingSessionExclusion({
    required VotingSessionExclusion votingSessionExclusion,
  }) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc('create_voting_session_exclusion',
          params: {'p_voting_session_exclusion': votingSessionExclusion.toJson()});
      return right(VotingSessionExclusion.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionExclusion>> updateVotingSessionExclusion({
    required VotingSessionExclusion votingSessionExclusion,
  }) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc('update_voting_session_exclusion',
          params: {'p_voting_session_exclusion': votingSessionExclusion.toJson()});
      return right(VotingSessionExclusion.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionExclusion>> deleteVotingSessionExclusionById({
    required String id,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_voting_session_exclusion_by_id', params: {'p_id': id});
      return right(VotingSessionExclusion.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionExclusion?>> getVotingSessionExclusionById({
    required String id,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_voting_session_exclusion_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(VotingSessionExclusion.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<VotingSessionExclusion>>>
      getVotingSessionExclusionsByVotingSessionJurationId({
    required String votingSessionJurationId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_exclusions_by_voting_session_juration_id',
          params: {'p_voting_session_juration_id': votingSessionJurationId});
      return right(res.map((e) => VotingSessionExclusion.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
