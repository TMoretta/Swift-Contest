import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_session_token.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

abstract interface class VotingSessionTokenService {
  Future<VotingSessionToken> createVotingSessionToken({
    required VotingSessionToken votingSessionToken,
  });

  Future<VotingSessionToken> updateVotingSessionTokenById({
    required String id,
    required VotingSessionToken votingSessionToken,
  });

  Future<Unit> deleteVotingSessionTokenById({required String id});

  Future<VotingSessionToken> getVotingSessionTokenById({
    required String id,
  });

  Future<VotingSessionToken> getVotingSessionTokenByVotingSessionId({
    required String votingSessionId,
  });
}

class VotingSessionTokenServiceImpl implements VotingSessionTokenService {
  final SupabaseClient _supabase;

  VotingSessionTokenServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<VotingSessionToken> createVotingSessionToken({
    required VotingSessionToken votingSessionToken,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_session_tokens')
          .insert(votingSessionToken.toJson())
          .select();
      return VotingSessionToken.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteVotingSessionTokenById({required String id}) async {
    try {
      await _supabase.from('voting_session_tokens').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionToken> getVotingSessionTokenById({
    required String id,
  }) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('voting_session_tokens').select().eq('id', id);
      return VotingSessionToken.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionToken> getVotingSessionTokenByVotingSessionId({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('voting_session_tokens').select().eq('voting_session_id', votingSessionId);
      return VotingSessionToken.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionToken> updateVotingSessionTokenById({
    required String id,
    required VotingSessionToken votingSessionToken,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_session_tokens')
          .update(votingSessionToken.toJson())
          .eq('id', id)
          .select();
      return VotingSessionToken.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
