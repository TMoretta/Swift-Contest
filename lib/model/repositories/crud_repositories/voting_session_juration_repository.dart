import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_session_juration.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class VotingSessionJurationRepository {
  Future<Either<Failure, VotingSessionJuration>> createVotingSessionJuration({
    required VotingSessionJuration votingSessionJuration,
  });

  Future<Either<Failure, VotingSessionJuration>> updateVotingSessionJuration({
    required VotingSessionJuration votingSessionJuration,
  });

  Future<Either<Failure, VotingSessionJuration>> deleteVotingSessionJurationById({
    required String id,
  });

  Future<Either<Failure, VotingSessionJuration?>> getVotingSessionJurationById({
    required String id,
  });

  Future<Either<Failure, VotingSessionJuration?>>
      getVotingSessionJurationByVotingSessionIdAndJurationId({
    required String votingSessionId,
    required String jurationId,
  });

  Future<Either<Failure, List<VotingSessionJuration>>> getVotingSessionJurationsByVotingSessionId({
    required String votingSessionId,
  });
}

//* Implementation
class VotingSessionJurationRepositoryImpl implements VotingSessionJurationRepository {
  final SupabaseClient _supabase;

  VotingSessionJurationRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<Either<Failure, VotingSessionJuration>> createVotingSessionJuration({
    required VotingSessionJuration votingSessionJuration,
  }) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc('create_voting_session_juration',
          params: {'p_voting_session_juration': votingSessionJuration.toJson()});
      return right(VotingSessionJuration.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionJuration>> updateVotingSessionJuration({
    required VotingSessionJuration votingSessionJuration,
  }) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc('update_voting_session_juration',
          params: {'p_voting_session_juration': votingSessionJuration.toJson()});
      return right(VotingSessionJuration.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionJuration>> deleteVotingSessionJurationById({
    required String id,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_voting_session_juration_by_id', params: {'p_id': id});
      return right(VotingSessionJuration.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionJuration?>> getVotingSessionJurationById({
    required String id,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_voting_session_juration_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(VotingSessionJuration.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionJuration?>>
      getVotingSessionJurationByVotingSessionIdAndJurationId({
    required String votingSessionId,
    required String jurationId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_vot_session_juration_by_voting_session_id_and_juration_id',
          params: {'p_voting_session_id': votingSessionId, 'p_juration_id': jurationId});
      if (res.isEmpty) {
        return right(null);
      }
      return right(VotingSessionJuration.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<VotingSessionJuration>>> getVotingSessionJurationsByVotingSessionId({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_jurations_by_voting_session_id',
          params: {'p_voting_session_id': votingSessionId});
      return right(res.map((e) => VotingSessionJuration.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
