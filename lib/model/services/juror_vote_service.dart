import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/juror_vote.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class JurorVoteService {
  Future<JurorVote> createJurorVote({required JurorVote jurorVote});

  Future<JurorVote> updateJurorVote({required JurorVote jurorVote});

  Future<Unit> deleteJurorVoteById({required String id});

  Future<JurorVote> getJurorVoteById({required String id});

  Future<List<JurorVote>> getJurorVotesByJurorVotingId({required String jurorVotingId});
}

//* Implementation
class JurorVoteServiceImpl implements JurorVoteService {
  final SupabaseClient _supabase;

  JurorVoteServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<JurorVote> createJurorVote({required JurorVote jurorVote}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'create_juror_vote', params: jurorVote.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'JurorVote creation failed');
      }
      return JurorVote.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<JurorVote> updateJurorVote({required JurorVote jurorVote}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'update_juror_vote',
          params: jurorVote.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'JurorVote update failed');
      }
      return JurorVote.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteJurorVoteById({required String id}) async {
    try {
      await _supabase.rpc('delete_juror_vote_by_id', params: {'p_id': id});
      return unit;
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<JurorVote> getJurorVoteById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_juror_vote_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        throw SafeException(message: 'No JurorVote found');
      }
      return JurorVote.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<JurorVote>> getJurorVotesByJurorVotingId({required String jurorVotingId}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_juror_votes_by_juror_voting_id',
          params: {'p_juror_voting_id': jurorVotingId});
      return res.map((e) => JurorVote.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}