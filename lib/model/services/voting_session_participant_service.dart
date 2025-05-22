import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_session_participant.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class VotingSessionParticipantService {
  Future<VotingSessionParticipant> createVotingSessionParticipant({
    required VotingSessionParticipant votingSessionParticipant,
  });

  Future<VotingSessionParticipant> updateVotingSessionParticipant({
    required VotingSessionParticipant votingSessionParticipant,
  });

  Future<Unit> deleteVotingSessionParticipantById({required String id});

  Future<VotingSessionParticipant> getVotingSessionParticipantById(
      {required String id});

  Future<VotingSessionParticipant>
  getVotingSessionParticipantByVotingSessionIdAndParticipantId({
    required String votingSessionId,
    required String participantId,
  });

  Future<List<VotingSessionParticipant>>
  getVotingSessionParticipantsByVotingSessionId({
    required String votingSessionId,
  });
}

//* Implementation
class VotingSessionParticipantServiceImpl
    implements VotingSessionParticipantService {
  final SupabaseClient _supabase;

  VotingSessionParticipantServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<VotingSessionParticipant> createVotingSessionParticipant({
    required VotingSessionParticipant votingSessionParticipant,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'create_voting_session_participant',
          params: votingSessionParticipant.toRpcJson());
      if (res.isEmpty) {
        throw UnsafeException(
            message: 'VotingSessionParticipant creation failed');
      }
      return VotingSessionParticipant.fromJson(res[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionParticipant> updateVotingSessionParticipant({
    required VotingSessionParticipant votingSessionParticipant,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'update_voting_session_participant',
          params: votingSessionParticipant.toRpcJson());
      if (res.isEmpty) {
        throw UnsafeException(
            message: 'VotingSessionParticipant update failed');
      }
      return VotingSessionParticipant.fromJson(res[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteVotingSessionParticipantById({required String id}) async {
    try {
      await _supabase.rpc('delete_voting_session_participant_by_id',
          params: {'p_id': id});
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionParticipant> getVotingSessionParticipantById(
      {required String id}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_participant_by_id',
          params: {'p_id': id});
      if (res.isEmpty) {
        throw UnsafeException(message: 'No VotingSessionParticipant found');
      }
      return VotingSessionParticipant.fromJson(res[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionParticipant>
  getVotingSessionParticipantByVotingSessionIdAndParticipantId({
    required String votingSessionId,
    required String participantId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_participant_by_voting_session_id_and_participant_id',
          params: {
            'p_voting_session_id': votingSessionId,
            'p_participant_id': participantId
          });
      if (res.isEmpty) {
        throw UnsafeException(message: 'No VotingSessionParticipant found');
      }
      return VotingSessionParticipant.fromJson(res[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<VotingSessionParticipant>>
  getVotingSessionParticipantsByVotingSessionId({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_participants_by_voting_session_id',
          params: {'p_voting_session_id': votingSessionId});
      return res
          .map((e) => VotingSessionParticipant.fromJson(e))
          .toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}