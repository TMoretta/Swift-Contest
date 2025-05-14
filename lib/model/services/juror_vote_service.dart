import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/juror_vote.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class JurorVoteService {
  Future<JurorVote> createJurorVote({required JurorVote jurorVote});

  Future<JurorVote> updateJurorVoteById({required String id, required JurorVote jurorVote});

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
      final List<Map<String, dynamic>> results =
          await _supabase.from('juror_votes').insert(jurorVote.toJson()).select();
      return JurorVote.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<JurorVote> updateJurorVoteById({required String id, required JurorVote jurorVote}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('juror_votes').update(jurorVote.toJson()).eq('id', id).select();
      return JurorVote.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteJurorVoteById({required String id}) async {
    try {
      await _supabase.from('juror_votes').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<JurorVote> getJurorVoteById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('juror_votes').select().eq('id', id);
      return JurorVote.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<JurorVote>> getJurorVotesByJurorVotingId({required String jurorVotingId}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('juror_votes').select().eq('juror_voting_id', jurorVotingId);
      if(results.isEmpty) {
        return [];
      }
      return results.map((e) => JurorVote.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
