import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/vote.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class VoteService {
  Future<Vote> createVote({required Vote vote});

  Future<Vote> updateVoteById({required String id, required Vote vote});

  Future<Unit> deleteVoteById({required String id});

  Future<Vote> getVoteById({required String id});

  Future<List<Vote>> getVotesByVotingId({required String votingId});
}

//* Implementation
class VoteServiceImpl implements VoteService {
  final SupabaseClient _supabase;

  VoteServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Vote> createVote({required Vote vote}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('votes').insert(vote.toJson()).select();
      return Vote.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Vote> updateVoteById({required String id, required Vote vote}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('votes').update(vote.toJson()).eq('id', id).select();
      return Vote.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteVoteById({required String id}) async {
    try {
      await _supabase.from('votes').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Vote> getVoteById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('votes').select().eq('id', id);
      return Vote.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Vote>> getVotesByVotingId({required String votingId}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('votes').select().eq('voting_id', votingId);
      if(results.isEmpty) {
        return [];
      }
      return results.map((e) => Vote.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
