import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_result_bundle.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class GenericRepository {
  Future<Either<Failure, ContestDetailsBundle>> getContestDetails({required String contestId});

  Future<Either<Failure, VotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
    required String votingSessionId,
  });

  Future<Either<Failure, VotingSessionResultBundle>> getVotingSessionResultBundle({
    required String votingSessionId,
  });
}

class GenericRepositoryImpl implements GenericRepository {
  final SupabaseClient _supabase;

  GenericRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, ContestDetailsBundle>> getContestDetails({
    required String contestId,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
      await _supabase.rpc('organizer_get_contest_details', params: {'p_contest_id': contestId});
      if (res.isEmpty) {
        return left(Failure(message: 'Contest not found'));
      }
      return right(ContestDetailsBundle.fromRpcJson(res.first));
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'organizer_get_voting_session_procedure_bundle',
          params: {'p_voting_session_id': votingSessionId});
      if (res.isEmpty) {
        return left(Failure(message: 'Voting session not found'));
      }
      return right(VotingSessionProcedureBundle.fromRpcJson(res.first));
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionResultBundle>> getVotingSessionResultBundle({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'organizer_get_voting_session_result_bundle',
          params: {'p_voting_session_id': votingSessionId});
      if (res.isEmpty) {
        return left(Failure(message: 'Voting session not found'));
      }
      return right(VotingSessionResultBundle.fromRpcJson(res.first));
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
