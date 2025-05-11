import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_session_participant.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class VotingSessionParticipantService {
  Future<VotingSessionParticipant> createVotingSessionParticipant(
      {required VotingSessionParticipant votingSessionParticipant,});

  Future<VotingSessionParticipant> updateVotingSessionParticipantById({required String id, required VotingSessionParticipant votingSessionParticipant,});

  Future<Unit> deleteVotingSessionParticipantById({required String id});

  Future<VotingSessionParticipant> getVotingSessionParticipantById({required String id});

  Future<VotingSessionParticipant> getVotingSessionParticipantByVotingSessionIdAndParticipantId({
    required String votingSessionId,
    required String participantId,
  });

  Future<List<VotingSessionParticipant>> getVotingSessionParticipantsByVotingSessionId({
    required String votingSessionId,
  });
}

//* Implementation
class VotingSessionParticipantServiceImpl implements VotingSessionParticipantService {
  final SupabaseClient _supabase;

  VotingSessionParticipantServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<VotingSessionParticipant> createVotingSessionParticipant(
      {required VotingSessionParticipant votingSessionParticipant,}) async {
    try {
      final List<Map<String, dynamic>> results =
      await _supabase.from('voting_session_participants').insert(votingSessionParticipant.toJson()).select();
      return VotingSessionParticipant.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionParticipant> updateVotingSessionParticipantById({required String id, required VotingSessionParticipant votingSessionParticipant,}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_session_participants')
          .update(votingSessionParticipant.toJson())
          .eq('id', id)
          .select();
      return VotingSessionParticipant.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteVotingSessionParticipantById({required String id}) async {
    try {
      await _supabase.from('voting_session_participants').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionParticipant> getVotingSessionParticipantById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
      await _supabase.from('voting_session_participants').select().eq('id', id);
      return VotingSessionParticipant.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionParticipant> getVotingSessionParticipantByVotingSessionIdAndParticipantId({
    required String votingSessionId,
    required String participantId,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_session_participants')
          .select()
          .eq('voting_session_id', votingSessionId)
          .eq('participant_id', participantId);
      return VotingSessionParticipant.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<VotingSessionParticipant>> getVotingSessionParticipantsByVotingSessionId({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_session_participants')
          .select()
          .eq('voting_session_id', votingSessionId);
      return results.map((e) => VotingSessionParticipant.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
