import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_session_simple_juror.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

abstract interface class VotingSessionSimpleJurorService {
  Future<VotingSessionSimpleJuror> createVotingSessionSimpleJuror({
    required VotingSessionSimpleJuror votingSessionSimpleJuror,
  });

  Future<VotingSessionSimpleJuror> updateVotingSessionSimpleJurorById({
    required String id,
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
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_session_simple_jurors')
          .insert(votingSessionSimpleJuror.toJson())
          .select();
      return VotingSessionSimpleJuror.fromJson(results[0]);
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
          .from('voting_session_simple_jurors')
          .delete()
          .eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionSimpleJuror> getVotingSessionSimpleJurorById({
    required String id,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_session_simple_jurors')
          .select()
          .eq('id', id);
      return VotingSessionSimpleJuror.fromJson(results[0]);
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
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_session_simple_jurors')
          .select()
          .eq('voting_session_id', votingSessionId);
      return results
          .map((e) => VotingSessionSimpleJuror.fromJson(e))
          .toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionSimpleJuror> updateVotingSessionSimpleJurorById({
    required String id,
    required VotingSessionSimpleJuror votingSessionSimpleJuror,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_session_simple_jurors')
          .update(votingSessionSimpleJuror.toJson())
          .eq('id', id)
          .select();
      return VotingSessionSimpleJuror.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
