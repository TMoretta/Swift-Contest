import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/simple_juror_vote.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class SimpleJurorVoteService {
  Future<SimpleJurorVote> createSimpleJurorVote({required SimpleJurorVote simpleJurorVote});

  Future<SimpleJurorVote> updateSimpleJurorVote({required SimpleJurorVote simpleJurorVote});

  Future<Unit> deleteSimpleJurorVoteById({required String id});

  Future<SimpleJurorVote> getSimpleJurorVoteById({required String id});

  Future<List<SimpleJurorVote>> getSimpleJurorVotesBySimpleJurorVotingId({required String simpleJurorVotingId});
}

//* Implementation
class SimpleJurorVoteServiceImpl implements SimpleJurorVoteService {
  final SupabaseClient _supabase;

  SimpleJurorVoteServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<SimpleJurorVote> createSimpleJurorVote({required SimpleJurorVote simpleJurorVote}) async {
    try {
      final List<Map<String, dynamic>> res =
      await _supabase.rpc('create_simple_juror_vote', params: simpleJurorVote.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'SimpleJurorVote creation failed');
      }
      return SimpleJurorVote.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<SimpleJurorVote> updateSimpleJurorVote({required SimpleJurorVote simpleJurorVote}) async {
    try {
      final List<Map<String, dynamic>> res =
      await _supabase.rpc('update_simple_juror_vote', params: simpleJurorVote.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'SimpleJurorVote update failed');
      }
      return SimpleJurorVote.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteSimpleJurorVoteById({required String id}) async {
    try {
      await _supabase.rpc('delete_simple_juror_vote_by_id', params: {'p_id': id});
      return unit;
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<SimpleJurorVote> getSimpleJurorVoteById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
      await _supabase.rpc('get_simple_juror_vote_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        throw SafeException(message: 'No SimpleJurorVote found');
      }
      return SimpleJurorVote.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<SimpleJurorVote>> getSimpleJurorVotesBySimpleJurorVotingId({required String simpleJurorVotingId}) async {
    try {
      final List<Map<String, dynamic>> res =
      await _supabase.rpc('get_simple_juror_votes_by_simple_juror_voting_id', params: {'p_simple_juror_voting_id': simpleJurorVotingId});
      return res.map((e) => SimpleJurorVote.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}