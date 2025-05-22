import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_session_simple_juror.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class VotingSessionSimpleJurorService {
  Future<VotingSessionSimpleJuror> createVotingSessionSimpleJuror({
    required VotingSessionSimpleJuror votingSessionSimpleJuror,
  });

  Future<VotingSessionSimpleJuror> updateVotingSessionSimpleJuror({
    required VotingSessionSimpleJuror votingSessionSimpleJuror,
  });

  Future<Unit> deleteVotingSessionSimpleJurorById({required String id});

  Future<VotingSessionSimpleJuror> getVotingSessionSimpleJurorById({
    required String id,
  });

  Future<List<VotingSessionSimpleJuror>>
  getVotingSessionSimpleJurorsByVotingSessionId({
    required String votingSessionId,
  });
}

//* Implementation
class VotingSessionSimpleJurorServiceImpl
    implements VotingSessionSimpleJurorService {
  final SupabaseClient _supabase;

  VotingSessionSimpleJurorServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<VotingSessionSimpleJuror> createVotingSessionSimpleJuror({
    required VotingSessionSimpleJuror votingSessionSimpleJuror,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'create_voting_session_simple_juror',
          params: votingSessionSimpleJuror.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'VotingSessionSimpleJuror creation failed');
      }
      return VotingSessionSimpleJuror.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteVotingSessionSimpleJurorById({
    required String id,
  }) async {
    try {
      await _supabase
          .rpc('delete_voting_session_simple_juror_by_id', params: {'p_id': id});
      return unit;
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionSimpleJuror> getVotingSessionSimpleJurorById({
    required String id,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_simple_juror_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        throw SafeException(message: 'No VotingSessionSimpleJuror found');
      }
      return VotingSessionSimpleJuror.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<VotingSessionSimpleJuror>>
  getVotingSessionSimpleJurorsByVotingSessionId({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_session_simple_jurors_by_voting_session_id',
          params: {'p_voting_session_id': votingSessionId});
      return res
          .map((e) => VotingSessionSimpleJuror.fromJson(e))
          .toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionSimpleJuror> updateVotingSessionSimpleJuror({
    required VotingSessionSimpleJuror votingSessionSimpleJuror,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'update_voting_session_simple_juror',
          params: votingSessionSimpleJuror.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'VotingSessionSimpleJuror update failed');
      }
      return VotingSessionSimpleJuror.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}