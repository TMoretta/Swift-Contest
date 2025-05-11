import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class VotingSessionService {
  Future<VotingSession> createVotingSession({
    required VotingSession votingSession,
  });

  Future<VotingSession> updateVotingSessionById({
    required String id,
    required VotingSession votingSession,
  });

  Future<Unit> deleteVotingSessionById({required String id});

  Future<VotingSession> getVotingSessionById({required String id});

  Future<List<VotingSession>> getVotingSessionsByContestId({
    required String contestId,
  });
}

//* Implementation
class VotingSessionServiceImpl implements VotingSessionService {
  final SupabaseClient _supabase;

  VotingSessionServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<VotingSession> createVotingSession({
    required VotingSession votingSession,
  }) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('voting_sessions').insert(votingSession.toJson()).select();
      return VotingSession.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSession> updateVotingSessionById({
    required String id,
    required VotingSession votingSession,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_sessions')
          .update(votingSession.toJson())
          .eq('id', id)
          .select();
      return VotingSession.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteVotingSessionById({required String id}) async {
    try {
      await _supabase.from('voting_sessions').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingSession> getVotingSessionById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('voting_sessions').select().eq('id', id);
      return VotingSession.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<VotingSession>> getVotingSessionsByContestId({required String contestId}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('voting_sessions').select().eq('contest_id', contestId);
      return results.map((e) => VotingSession.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
