import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_session_procedure.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

abstract interface class VotingSessionProcedureService {
  Future<VotingSessionProcedure> createVotingSessionProcedure({
    required VotingSessionProcedure votingSessionProcedure,
  });

  Future<VotingSessionProcedure> updateVotingSessionProcedureById({
    required String id,
    required VotingSessionProcedure votingSessionProcedure,
  });

  Future<Unit> deleteVotingSessionProcedureById({required String id});

  Future<VotingSessionProcedure> getVotingSessionProcedureById({
    required String id,
  });

  Future<VotingSessionProcedure> getVotingSessionProcedureByVotingSessionId({
    required String votingSessionId,
  });

  Future<Unit> beginVotingSessionProcedureById({
    required String id,
  });

  Future<Unit> startVotingSessionProcedureById({
    required String id,
  });

  Future<Unit> cancelVotingSessionProcedureById({
    required String id,
  });

  Future<Stream<VotingSessionProcedure>> getVotingSessionProcedureStream({
    required String votingSessionProcedureId,
  });
}

class VotingSessionProcedureServiceImpl implements VotingSessionProcedureService {
  final SupabaseClient _supabase;

  VotingSessionProcedureServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<VotingSessionProcedure> createVotingSessionProcedure({
    required VotingSessionProcedure votingSessionProcedure,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_session_procedures')
          .insert(votingSessionProcedure.toJson())
          .select();
      return VotingSessionProcedure.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteVotingSessionProcedureById({required String id}) async {
    try {
      await _supabase.from('voting_session_procedures').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionProcedure> getVotingSessionProcedureById({
    required String id,
  }) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('voting_session_procedures').select().eq('id', id);
      return VotingSessionProcedure.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionProcedure> getVotingSessionProcedureByVotingSessionId({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_session_procedures')
          .select()
          .eq('voting_session_id', votingSessionId);
      return VotingSessionProcedure.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSessionProcedure> updateVotingSessionProcedureById({
    required String id,
    required VotingSessionProcedure votingSessionProcedure,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_session_procedures')
          .update(votingSessionProcedure.toJson())
          .eq('id', id)
          .select();
      return VotingSessionProcedure.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> beginVotingSessionProcedureById({required String id}) async {
    try {
      await _supabase.rpc('begin_voting_session_procedure_by_id', params: {'p_id': id});
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> startVotingSessionProcedureById({
    required String id,
  }) async {
    try {
      await _supabase.rpc('start_voting_session_procedure_by_id', params: {'p_id': id});
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> cancelVotingSessionProcedureById({
    required String id,
  }) async {
    try {
      await _supabase.rpc('cancel_voting_session_procedure_by_id', params: {'p_id': id});
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Stream<VotingSessionProcedure>> getVotingSessionProcedureStream({
    required String votingSessionProcedureId,
  }) async {
    return _supabase
        .from('voting_session_procedures')
        .stream(primaryKey: ['id'])
        .eq('id', votingSessionProcedureId)
        .timeout(Duration(hours: 24))
        .map((rows) => VotingSessionProcedure.fromJson(rows.first));
  }

}

