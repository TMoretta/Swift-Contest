import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/simple_juror_voting.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class SimpleJurorVotingRepository {
  Future<Either<Failure, SimpleJurorVoting>> createSimpleJurorVoting({
    required SimpleJurorVoting simpleJurorVoting,
  });

  Future<Either<Failure, SimpleJurorVoting>> updateSimpleJurorVoting({
    required SimpleJurorVoting simpleJurorVoting,
  });

  Future<Either<Failure, SimpleJurorVoting>> deleteSimpleJurorVotingById({required String id});

  Future<Either<Failure, SimpleJurorVoting?>> getSimpleJurorVotingById({
    required String id,
  });

  Future<Either<Failure, List<SimpleJurorVoting>>>
      getSimpleJurorVotingsByVotingSessionSimpleJurorId({
    required String votingSessionSimpleJurorId,
  });

  Future<Either<Failure, SimpleJurorVoting?>>
      getSimpleJurorVotingByVotingSessionSimpleJurorIdAndVotingSessionParticipationId({
    required String votingSessionSimpleJurorId,
    required String votingSessionParticipationId,
  });
}

//* Implementation
class SimpleJurorVotingRepositoryImpl implements SimpleJurorVotingRepository {
  final SupabaseClient _supabase;

  SimpleJurorVotingRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<Either<Failure, SimpleJurorVoting>> createSimpleJurorVoting({
    required SimpleJurorVoting simpleJurorVoting,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('create_simple_juror_voting', params: {'p_simple_juror_voting': simpleJurorVoting.toJson()});
      return right(SimpleJurorVoting.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVoting>> updateSimpleJurorVoting({
    required SimpleJurorVoting simpleJurorVoting,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('update_simple_juror_voting', params: {'p_simple_juror_voting': simpleJurorVoting.toJson()});
      return right(SimpleJurorVoting.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVoting>> deleteSimpleJurorVotingById({
    required String id,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_simple_juror_voting_by_id', params: {'p_id': id});
      return right(SimpleJurorVoting.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVoting?>> getSimpleJurorVotingById({
    required String id,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_simple_juror_voting_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(SimpleJurorVoting.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<SimpleJurorVoting>>>
      getSimpleJurorVotingsByVotingSessionSimpleJurorId({
    required String votingSessionSimpleJurorId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_simple_juror_votings_by_voting_session_simple_juror_id',
          params: {'p_voting_session_simple_juror_id': votingSessionSimpleJurorId});
      return right(res.map((e) => SimpleJurorVoting.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVoting?>>
      getSimpleJurorVotingByVotingSessionSimpleJurorIdAndVotingSessionParticipationId({
    required String votingSessionSimpleJurorId,
    required String votingSessionParticipationId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('get_simple_jur_voting_by_vot_ses_sim_jur_id_and_vot_ses_par_id', params: {
        'p_voting_session_simple_juror_id': votingSessionSimpleJurorId,
        'p_voting_session_participation_id': votingSessionParticipationId
      });
      if (res.isEmpty) {
        return right(null);
      }
      return right(SimpleJurorVoting.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
