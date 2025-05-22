import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class VotingSessionService {
  Future<VotingSession> createVotingSession({required VotingSession votingSession});

  Future<VotingSession> updateVotingSession({required VotingSession votingSession});

  Future<Unit> deleteVotingSessionById({required String id});

  Future<VotingSession> getVotingSessionById({required String id});

  Future<List<VotingSession>> getVotingSessionsByContestId({required String contestId});

  Future<VotingSession> getVotingSessionByToken({required String token});
}

//* Implementation
class VotingSessionServiceImpl implements VotingSessionService {
  final SupabaseClient _supabase;

  VotingSessionServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<VotingSession> createVotingSession({required VotingSession votingSession}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'create_voting_session', params: votingSession.toRpcJson());
      if (res.isEmpty) {
        throw UnsafeException(message: 'VotingSession creation failed');
      }
      return VotingSession.fromJson(res[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSession> updateVotingSession({required VotingSession votingSession}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'update_voting_session', params: votingSession.toRpcJson());
      if (res.isEmpty) {
        throw UnsafeException(message: 'VotingSession update failed');
      }
      return VotingSession.fromJson(res[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteVotingSessionById({required String id}) async {
    try {
      await _supabase
          .rpc('delete_voting_session_by_id', params: {'p_id': id});
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSession> getVotingSessionById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        throw UnsafeException(message: 'No VotingSession found');
      }
      return VotingSession.fromJson(res[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<VotingSession>> getVotingSessionsByContestId({required String contestId}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_sessions_by_contest_id',
          params: {'p_contest_id': contestId});
      return res
          .map((e) => VotingSession.fromJson(e))
          .toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSession> getVotingSessionByToken({required String token}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_by_token', params: {'p_token': token});
      if (res.isEmpty) {
        throw UnsafeException(message: 'No VotingSession found');
      }
      return VotingSession.fromJson(res[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}