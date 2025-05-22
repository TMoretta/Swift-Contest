import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_session_juror.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class VotingSessionJurorService {
  Future<VotingSessionJuror> createVotingSessionJuror({
    required VotingSessionJuror votingSessionJuror,
  });

  Future<VotingSessionJuror> updateVotingSessionJuror({
    required VotingSessionJuror votingSessionJuror,
  });

  Future<Unit> deleteVotingSessionJurorById({required String id});

  Future<VotingSessionJuror> getVotingSessionJurorById({required String id});

  Future<VotingSessionJuror> getVotingSessionJurorByVotingSessionIdAndJurorId({
    required String votingSessionId,
    required String jurorId,
  });

  Future<List<VotingSessionJuror>> getVotingSessionJurorsByVotingSessionId({
    required String votingSessionId,
  });
}

//* Implementation
class VotingSessionJurorServiceImpl implements VotingSessionJurorService {
  final SupabaseClient _supabase;

  VotingSessionJurorServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<VotingSessionJuror> createVotingSessionJuror(
      {required VotingSessionJuror votingSessionJuror}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'create_voting_session_juror',
          params: votingSessionJuror.toRpcJson());
      if (res.isEmpty) {
        throw UnsafeException(message: 'VotingSessionJuror creation failed');
      }
      return VotingSessionJuror.fromJson(res[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionJuror> updateVotingSessionJuror({
    required VotingSessionJuror votingSessionJuror,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'update_voting_session_juror',
          params: votingSessionJuror.toRpcJson());
      if (res.isEmpty) {
        throw UnsafeException(message: 'VotingSessionJuror update failed');
      }
      return VotingSessionJuror.fromJson(res[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteVotingSessionJurorById({required String id}) async {
    try {
      await _supabase
          .rpc('delete_voting_session_juror_by_id', params: {'p_id': id});
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionJuror> getVotingSessionJurorById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_juror_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        throw UnsafeException(message: 'No VotingSessionJuror found');
      }
      return VotingSessionJuror.fromJson(res[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionJuror> getVotingSessionJurorByVotingSessionIdAndJurorId({
    required String votingSessionId,
    required String jurorId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_juror_by_voting_session_id_and_juror_id',
          params: {'p_voting_session_id': votingSessionId, 'p_juror_id': jurorId});
      if (res.isEmpty) {
        throw UnsafeException(message: 'No VotingSessionJuror found');
      }
      return VotingSessionJuror.fromJson(res[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<VotingSessionJuror>> getVotingSessionJurorsByVotingSessionId({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_jurors_by_voting_session_id',
          params: {'p_voting_session_id': votingSessionId});
      return res
          .map((e) => VotingSessionJuror.fromJson(e))
          .toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}