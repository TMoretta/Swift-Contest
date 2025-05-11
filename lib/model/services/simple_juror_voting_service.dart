import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/simple_juror_voting.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

abstract interface class SimpleJurorVotingService {
  Future<SimpleJurorVoting> createSimpleJurorVoting({
    required SimpleJurorVoting simpleJurorVoting,
  });

  Future<SimpleJurorVoting> updateSimpleJurorVotingById({
    required String id,
    required SimpleJurorVoting simpleJurorVoting,
  });

  Future<Unit> deleteSimpleJurorVotingById({required String id});

  Future<SimpleJurorVoting> getSimpleJurorVotingById({
    required String id,
  });

  Future<List<SimpleJurorVoting>>
      getSimpleJurorVotingsByVotingSessionSimpleJurorId({
    required String votingSessionSimpleJurorId,
  });
}

class SimpleJurorVotingServiceImpl implements SimpleJurorVotingService {
  final SupabaseClient _supabase;

  SimpleJurorVotingServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<SimpleJurorVoting> createSimpleJurorVoting({
    required SimpleJurorVoting simpleJurorVoting,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('simple_juror_votings')
          .insert(simpleJurorVoting.toJson())
          .select();
      return SimpleJurorVoting.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteSimpleJurorVotingById({
    required String id,
  }) async {
    try {
      await _supabase.from('simple_juror_votings').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<SimpleJurorVoting> getSimpleJurorVotingById({
    required String id,
  }) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('simple_juror_votings').select().eq('id', id);
      return SimpleJurorVoting.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<SimpleJurorVoting>>
      getSimpleJurorVotingsByVotingSessionSimpleJurorId({
    required String votingSessionSimpleJurorId,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('simple_juror_votings')
          .select()
          .eq('voting_session_simple_juror_id', votingSessionSimpleJurorId);
      return results
          .map((e) => SimpleJurorVoting.fromJson(e))
          .toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<SimpleJurorVoting> updateSimpleJurorVotingById({
    required String id,
    required SimpleJurorVoting simpleJurorVoting,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('simple_juror_votings')
          .update(simpleJurorVoting.toJson())
          .eq('id', id)
          .select();
      return SimpleJurorVoting.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
