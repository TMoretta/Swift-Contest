import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/juror_voting.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class JurorVotingRepository {
  Future<Either<Failure, JurorVoting>> createJurorVoting({
    required JurorVoting jurorVoting,
  });

  Future<Either<Failure, JurorVoting>> updateJurorVoting({
    required JurorVoting jurorVoting,
  });

  Future<Either<Failure, JurorVoting>> deleteJurorVotingById({
    required String id,
  });

  Future<Either<Failure, JurorVoting?>> getJurorVotingById({
    required String id,
  });

  Future<Either<Failure, JurorVoting?>>
      getJurorVotingByVotingSessionJurationIdAndVotingSessionParticipationId({
    required String votingSessionJurationId,
    required String votingSessionParticipationId,
  });

  Future<Either<Failure, List<JurorVoting>>> getJurorVotingsByVotingSessionParticipationId({
    required String votingSessionParticipationId,
  });

  Future<Either<Failure, List<JurorVoting>>> getJurorVotingsByVotingSessionJurationId({
    required String votingSessionJurationId,
  });
}

//* Implementation
class JurorVotingRepositoryImpl implements JurorVotingRepository {
  final SupabaseClient _supabase;

  JurorVotingRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, JurorVoting>> createJurorVoting({
    required JurorVoting jurorVoting,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('create_juror_voting', params: {'p_juror_voting': jurorVoting.toJson()});
      return right(JurorVoting.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, JurorVoting>> updateJurorVoting({
    required JurorVoting jurorVoting,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('update_juror_voting', params: {'p_juror_voting': jurorVoting.toJson()});
      return right(JurorVoting.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, JurorVoting>> deleteJurorVotingById({
    required String id,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_juror_voting_by_id', params: {'p_id': id});
      return right(JurorVoting.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, JurorVoting?>> getJurorVotingById({
    required String id,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_juror_voting_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(JurorVoting.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, JurorVoting?>>
      getJurorVotingByVotingSessionJurationIdAndVotingSessionParticipationId({
    required String votingSessionJurationId,
    required String votingSessionParticipationId,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_juror_voting_by_vot_ses_jur_id_and_vot_ses_par_id', params: {
        'p_voting_session_juration_id': votingSessionJurationId,
        'p_voting_session_participation_id': votingSessionParticipationId,
      });
      if (res.isEmpty) {
        return right(null);
      }
      return right(JurorVoting.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<JurorVoting>>> getJurorVotingsByVotingSessionParticipationId({
    required String votingSessionParticipationId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_juror_votings_by_voting_session_participation_id',
          params: {'p_voting_session_participation_id': votingSessionParticipationId});
      return right(res.map((e) => JurorVoting.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<JurorVoting>>> getJurorVotingsByVotingSessionJurationId({
    required String votingSessionJurationId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_juror_votings_by_voting_session_juration_id',
          params: {'p_voting_session_juration_id': votingSessionJurationId});
      return right(res.map((e) => JurorVoting.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
