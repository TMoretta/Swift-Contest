import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class VotingSessionParticipationRepository {
  Future<Either<Failure, VotingSessionParticipation>> createVotingSessionParticipation({
    required VotingSessionParticipation votingSessionParticipation,
  });

  Future<Either<Failure, VotingSessionParticipation>> updateVotingSessionParticipation({
    required VotingSessionParticipation votingSessionParticipation,
  });

  Future<Either<Failure, VotingSessionParticipation>> deleteVotingSessionParticipationById({
    required String id,
  });

  Future<Either<Failure, VotingSessionParticipation?>> getVotingSessionParticipationById({
    required String id,
  });

  Future<Either<Failure, VotingSessionParticipation?>>
      getVotingSessionParticipationByVotingSessionIdAndParticipationId({
    required String votingSessionId,
    required String participationId,
  });

  Future<Either<Failure, List<VotingSessionParticipation>>>
      getVotingSessionParticipationsByVotingSessionId({
    required String votingSessionId,
  });
}

//* Implementation
class VotingSessionParticipationRepositoryImpl implements VotingSessionParticipationRepository {
  final SupabaseClient _supabase;

  VotingSessionParticipationRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<Either<Failure, VotingSessionParticipation>> createVotingSessionParticipation({
    required VotingSessionParticipation votingSessionParticipation,
  }) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc('create_voting_session_participation',
          params: {'p_voting_session_participation': votingSessionParticipation.toJson()});
      return right(VotingSessionParticipation.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionParticipation>> updateVotingSessionParticipation({
    required VotingSessionParticipation votingSessionParticipation,
  }) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc('update_voting_session_participation',
          params: {'p_voting_session_participation': votingSessionParticipation.toJson()});
      return right(VotingSessionParticipation.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionParticipation>> deleteVotingSessionParticipationById({
    required String id,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_voting_session_participation_by_id', params: {'p_id': id});
      return right(VotingSessionParticipation.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionParticipation?>> getVotingSessionParticipationById({
    required String id,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_voting_session_participation_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(VotingSessionParticipation.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionParticipation?>>
      getVotingSessionParticipationByVotingSessionIdAndParticipationId({
    required String votingSessionId,
    required String participationId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_participation_by_voting_session_id_and_participation_id',
          params: {'p_voting_session_id': votingSessionId, 'p_participation_id': participationId});
      if (res.isEmpty) {
        return right(null);
      }
      return right(VotingSessionParticipation.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<VotingSessionParticipation>>>
      getVotingSessionParticipationsByVotingSessionId({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_participations_by_voting_session_id',
          params: {'p_voting_session_id': votingSessionId});
      return right(res.map((e) => VotingSessionParticipation.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
