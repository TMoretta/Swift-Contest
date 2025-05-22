import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/juror_voting.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class JurorVotingService {
  Future<JurorVoting> createJurorVoting({required JurorVoting jurorVoting});

  Future<JurorVoting> updateJurorVoting({required JurorVoting jurorVoting});

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
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'create_juror_voting', params: jurorVoting.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'JurorVoting creation failed');
      }
      return JurorVoting.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<JurorVoting> updateJurorVoting({required JurorVoting jurorVoting}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'update_juror_voting',
          params: jurorVoting.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'JurorVoting update failed');
      }
      return JurorVoting.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteJurorVotingById({required String id}) async {
    try {
      await _supabase.rpc('delete_juror_voting_by_id', params: {'p_id': id});
      return unit;
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<JurorVoting> getJurorVotingById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_juror_voting_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        throw SafeException(message: 'No JurorVoting found');
      }
      return JurorVoting.fromJson(res[0]);
    } on SafeException {
      rethrow;
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
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_juror_voting_by_voting_session_juror_id_and_voting_session_participant_id',
          params: {
            'p_voting_session_juror_id': votingSessionJurorId,
            'p_voting_session_participant_id': votingSessionParticipantId,
          });
      if (res.isEmpty) {
        throw SafeException(message: 'No JurorVoting found');
      }
      return JurorVoting.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<JurorVoting>> getJurorVotingsByVotingSessionParticipantId({
    required String votingSessionParticipantId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_juror_votings_by_voting_session_participant_id',
          params: {'p_voting_session_participant_id': votingSessionParticipantId});
      return res.map((e) => JurorVoting.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<JurorVoting>> getJurorVotingsByVotingSessionJurorId(
      {required String votingSessionJurorId}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_juror_votings_by_voting_session_juror_id',
          params: {'p_voting_session_juror_id': votingSessionJurorId});
      return res.map((e) => JurorVoting.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}