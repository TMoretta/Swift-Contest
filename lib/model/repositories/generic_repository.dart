import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/bundles/voting_session_procedure_bundle.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class GenericRepository {
  Future<Either<Failure, VotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
    required String votingSessionId,
  });
}

class GenericRepositoryImpl implements GenericRepository {
  final SupabaseClient _supabase;

  GenericRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, VotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_procedure_bundle',
          params: {'p_voting_session_id': votingSessionId});
      if (res.isEmpty) {
        return left(Failure(message: 'Voting session not found'));
      }
      return right(VotingSessionProcedureBundle.fromRpcJson(res.first));
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
