import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/simple_juror_voting.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class SimpleJurorVotingService {
  Future<SimpleJurorVoting> createSimpleJurorVoting({
    required SimpleJurorVoting simpleJurorVoting,
  });

  Future<SimpleJurorVoting> updateSimpleJurorVoting({
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

  Future<SimpleJurorVoting>
  getVotingByVotingSessionSimpleJurorIdAndVotingSessionParticipantId({
    required String votingSessionSimpleJurorId,
    required String votingSessionParticipantId,
  });
}

//* Implementation
class SimpleJurorVotingServiceImpl implements SimpleJurorVotingService {
  final SupabaseClient _supabase;

  SimpleJurorVotingServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<SimpleJurorVoting> createSimpleJurorVoting({
    required SimpleJurorVoting simpleJurorVoting,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'create_simple_juror_voting',
          params: simpleJurorVoting.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'SimpleJurorVoting creation failed');
      }
      return SimpleJurorVoting.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteSimpleJurorVotingById({
    required String id,
  }) async {
    try {
      await _supabase
          .rpc('delete_simple_juror_voting_by_id', params: {'p_id': id});
      return unit;
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<SimpleJurorVoting> getSimpleJurorVotingById({
    required String id,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('get_simple_juror_voting_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        throw SafeException(message: 'No SimpleJurorVoting found');
      }
      return SimpleJurorVoting.fromJson(res[0]);
    } on SafeException {
      rethrow;
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
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_simple_juror_votings_by_voting_session_simple_juror_id',
          params: {'p_voting_session_simple_juror_id': votingSessionSimpleJurorId});
      return res
          .map((e) => SimpleJurorVoting.fromJson(e))
          .toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<SimpleJurorVoting> updateSimpleJurorVoting({
    required SimpleJurorVoting simpleJurorVoting,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'update_simple_juror_voting',
          params: simpleJurorVoting.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'SimpleJurorVoting update failed');
      }
      return SimpleJurorVoting.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<SimpleJurorVoting>
  getVotingByVotingSessionSimpleJurorIdAndVotingSessionParticipantId({
    required String votingSessionSimpleJurorId,
    required String votingSessionParticipantId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_by_voting_session_simple_juror_id_and_voting_session_participant_id',
          params: {
            'p_voting_session_simple_juror_id': votingSessionSimpleJurorId,
            'p_voting_session_participant_id': votingSessionParticipantId
          });
      if (res.isEmpty) {
        throw SafeException(message: 'No SimpleJurorVoting found');
      }
      return SimpleJurorVoting.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}