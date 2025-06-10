import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/simple_juror_vote.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class SimpleJurorVoteRepository {
  Future<Either<Failure, SimpleJurorVote>> createSimpleJurorVote({
    required SimpleJurorVote simpleJurorVote,
  });

  Future<Either<Failure, SimpleJurorVote>> updateSimpleJurorVote({
    required SimpleJurorVote simpleJurorVote,
  });

  Future<Either<Failure, SimpleJurorVote>> deleteSimpleJurorVoteById({
    required String id,
  });

  Future<Either<Failure, SimpleJurorVote?>> getSimpleJurorVoteById({
    required String id,
  });

  Future<Either<Failure, List<SimpleJurorVote>>> getSimpleJurorVotesBySimpleJurorVotingId({
    required String simpleJurorVotingId,
  });
}

//* Implementation
class SimpleJurorVoteRepositoryImpl implements SimpleJurorVoteRepository {
  final SupabaseClient _supabase;

  SimpleJurorVoteRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<Either<Failure, SimpleJurorVote>> createSimpleJurorVote(
      {required SimpleJurorVote simpleJurorVote}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('create_simple_juror_vote', params: {'p_simple_juror_vote': simpleJurorVote.toJson()});
      return right(SimpleJurorVote.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVote>> updateSimpleJurorVote(
      {required SimpleJurorVote simpleJurorVote}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('update_simple_juror_vote', params: {'p_simple_juror_vote': simpleJurorVote.toJson()});
      return right(SimpleJurorVote.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVote>> deleteSimpleJurorVoteById({required String id}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_simple_juror_vote_by_id', params: {'p_id': id});
      return right(SimpleJurorVote.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVote?>> getSimpleJurorVoteById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_simple_juror_vote_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(SimpleJurorVote.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<SimpleJurorVote>>> getSimpleJurorVotesBySimpleJurorVotingId(
      {required String simpleJurorVotingId}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_simple_juror_votes_by_simple_juror_voting_id',
          params: {'p_simple_juror_voting_id': simpleJurorVotingId});
      return right(res.map((e) => SimpleJurorVote.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
