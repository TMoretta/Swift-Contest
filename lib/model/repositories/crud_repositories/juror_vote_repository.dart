import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/juror_vote.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class JurorVoteRepository {
  Future<Either<Failure, JurorVote>> createJurorVote({
    required JurorVote jurorVote,
  });

  Future<Either<Failure, JurorVote>> updateJurorVote({
    required JurorVote jurorVote,
  });

  Future<Either<Failure, JurorVote>> deleteJurorVoteById({
    required String id,
  });

  Future<Either<Failure, JurorVote?>> getJurorVoteById({required String id});

  Future<Either<Failure, List<JurorVote>>> getJurorVotesByJurorVotingId({
    required String jurorVotingId,
  });
}

//* Implementation
class JurorVoteRepositoryImpl implements JurorVoteRepository {
  final SupabaseClient _supabase;

  JurorVoteRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, JurorVote>> createJurorVote({
    required JurorVote jurorVote,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('create_juror_vote', params: {'p_juror_vote': jurorVote.toJson()});
      return right(JurorVote.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, JurorVote>> updateJurorVote({required JurorVote jurorVote}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('update_juror_vote', params: {'p_juror_vote': jurorVote.toJson()});
      return right(JurorVote.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, JurorVote>> deleteJurorVoteById({required String id}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_juror_vote_by_id', params: {'p_id': id});
      return right(JurorVote.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, JurorVote?>> getJurorVoteById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_juror_vote_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(JurorVote.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<JurorVote>>> getJurorVotesByJurorVotingId({
    required String jurorVotingId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('get_juror_votes_by_juror_voting_id', params: {'p_juror_voting_id': jurorVotingId});
      return right(res.map((e) => JurorVote.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
