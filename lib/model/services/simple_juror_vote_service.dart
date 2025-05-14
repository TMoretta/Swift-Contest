import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/simple_juror_vote.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class SimpleJurorVoteService {
  Future<SimpleJurorVote> createSimpleJurorVote({required SimpleJurorVote simpleJurorVote});

  Future<SimpleJurorVote> updateSimpleJurorVoteById({required String id, required SimpleJurorVote simpleJurorVote});

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
      final List<Map<String, dynamic>> results =
      await _supabase.from('simple_juror_votes').insert(simpleJurorVote.toJson()).select();
      return SimpleJurorVote.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<SimpleJurorVote> updateSimpleJurorVoteById({required String id, required SimpleJurorVote simpleJurorVote}) async {
    try {
      final List<Map<String, dynamic>> results =
      await _supabase.from('simple_juror_votes').update(simpleJurorVote.toJson()).eq('id', id).select();
      return SimpleJurorVote.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteSimpleJurorVoteById({required String id}) async {
    try {
      await _supabase.from('simple_juror_votes').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<SimpleJurorVote> getSimpleJurorVoteById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
      await _supabase.from('simple_juror_votes').select().eq('id', id);
      return SimpleJurorVote.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<SimpleJurorVote>> getSimpleJurorVotesBySimpleJurorVotingId({required String simpleJurorVotingId}) async {
    try {
      final List<Map<String, dynamic>> results =
      await _supabase.from('simple_juror_votes').select().eq('simple_juror_voting_id', simpleJurorVotingId);
      if(results.isEmpty) {
        return [];
      }
      return results.map((e) => SimpleJurorVote.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
