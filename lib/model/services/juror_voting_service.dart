import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/juror_voting.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class JurorVotingService {
  Future<JurorVoting> createJurorVoting({required JurorVoting jurorVoting});

  Future<JurorVoting> updateJurorVotingById({required String id, required JurorVoting jurorVoting});

  Future<Unit> deleteJurorVotingById({required String id});

  Future<JurorVoting> getJurorVotingById({required String id});

  Future<JurorVoting> getJurorVotingByVotingSessionJurorIdAndVotingSessionParticipantId({
    required String votingSessionJurorId,
    required String votingSessionParticipantId,
  });

  Future<List<JurorVoting>> getJurorVotingsByVotingSessionParticipantId({
    required String votingSessionParticipantId,
  });

  Future<List<JurorVoting>> getJurorVotingsByVotingSessionJurorId({
    required String votingSessionJurorId,
  });
}

//* Implementation
class JurorVotingServiceImpl implements JurorVotingService {
  final SupabaseClient _supabase;

  JurorVotingServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<JurorVoting> createJurorVoting({required JurorVoting jurorVoting}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('juror_votings').insert(jurorVoting.toJson()).select();
      return JurorVoting.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<JurorVoting> updateJurorVotingById({required String id, required JurorVoting jurorVoting}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('juror_votings')
          .update(jurorVoting.toJson())
          .eq('id', id)
          .select();
      return JurorVoting.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteJurorVotingById({required String id}) async {
    try {
      await _supabase.from('juror_votings').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<JurorVoting> getJurorVotingById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
      await _supabase.from('juror_votings').select().eq('id', id);
      return JurorVoting.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<JurorVoting> getJurorVotingByVotingSessionJurorIdAndVotingSessionParticipantId({
    required String votingSessionJurorId,
    required String votingSessionParticipantId,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('juror_votings')
          .select()
          .eq('voting_session_juror_id', votingSessionJurorId)
          .eq('voting_session_participant_id', votingSessionParticipantId);
      return JurorVoting.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<JurorVoting>> getJurorVotingsByVotingSessionParticipantId({
    required String votingSessionParticipantId,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('juror_votings')
          .select()
          .eq('voting_session_participant_id', votingSessionParticipantId);
      if(results.isEmpty) {
        return [];
      }
      return results.map((e) => JurorVoting.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<JurorVoting>> getJurorVotingsByVotingSessionJurorId(
      {required String votingSessionJurorId}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('juror_votings')
          .select()
          .eq('voting_session_juror_id', votingSessionJurorId);
      if(results.isEmpty) {
        return [];
      }
      return results.map((e) => JurorVoting.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
