import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class VotingService {
  Future<Voting> createVoting({required Voting voting});

  Future<Voting> updateVotingById({required String id, required Voting voting});

  Future<Unit> deleteVotingById({required String id});

  Future<Voting> getVotingById({required String id});

  Future<Voting> getVotingByVotingSessionJurorIdAndVotingSessionParticipantId({
    required String votingSessionJurorId,
    required String votingSessionParticipantId,
  });

  Future<List<Voting>> getVotingsByVotingSessionParticipantId({
    required String votingSessionParticipantId,
  });

  Future<List<Voting>> getVotingsByVotingSessionJurorId({
    required String votingSessionJurorId,
  });
}

//* Implementation
class VotingServiceImpl implements VotingService {
  final SupabaseClient _supabase;

  VotingServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Voting> createVoting({required Voting voting}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('votings').insert(voting.toJson()).select();
      return Voting.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Voting> updateVotingById({required String id, required Voting voting}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('votings')
          .update(voting.toJson())
          .eq('id', id)
          .select();
      return Voting.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteVotingById({required String id}) async {
    try {
      await _supabase.from('votings').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Voting> getVotingById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
      await _supabase.from('votings').select().eq('id', id);
      return Voting.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Voting> getVotingByVotingSessionJurorIdAndVotingSessionParticipantId({
    required String votingSessionJurorId,
    required String votingSessionParticipantId,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('votings')
          .select()
          .eq('voting_session_juror_id', votingSessionJurorId)
          .eq('voting_session_participant_id', votingSessionParticipantId);
      return Voting.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Voting>> getVotingsByVotingSessionParticipantId({
    required String votingSessionParticipantId,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('votings')
          .select()
          .eq('voting_session_participant_id', votingSessionParticipantId);
      if(results.isEmpty) {
        return [];
      }
      return results.map((e) => Voting.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Voting>> getVotingsByVotingSessionJurorId(
      {required String votingSessionJurorId}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('votings')
          .select()
          .eq('voting_session_juror_id', votingSessionJurorId);
      if(results.isEmpty) {
        return [];
      }
      return results.map((e) => Voting.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
