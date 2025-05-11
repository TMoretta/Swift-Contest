import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_session_juror.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class VotingSessionJurorService {
  Future<VotingSessionJuror> createVotingSessionJuror({
    required VotingSessionJuror votingSessionJuror,
  });

  Future<VotingSessionJuror> updateVotingSessionJurorById({required String id, required VotingSessionJuror votingSessionJuror,});

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
      final List<Map<String, dynamic>> results =
          await _supabase.from('voting_session_jurors').insert(votingSessionJuror.toJson()).select();
      return VotingSessionJuror.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionJuror> updateVotingSessionJurorById({required String id, required VotingSessionJuror votingSessionJuror,}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_session_jurors')
          .update(votingSessionJuror.toJson())
          .eq('id', id)
          .select();
      return VotingSessionJuror.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteVotingSessionJurorById({required String id}) async {
    try {
      await _supabase.from('voting_session_jurors').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionJuror> getVotingSessionJurorById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('voting_session_jurors').select().eq('id', id);
      return VotingSessionJuror.fromJson(results[0]);
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
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_session_jurors')
          .select()
          .eq('voting_session_id', votingSessionId)
          .eq('juror_id', jurorId);
      return VotingSessionJuror.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<VotingSessionJuror>> getVotingSessionJurorsByVotingSessionId({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_session_jurors')
          .select()
          .eq('voting_session_id', votingSessionId);
      return results.map((e) => VotingSessionJuror.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
