import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class ParticipationService {
  Future<Participation> createParticipation({required Participation participation});

  Future<Participation> updateParticipation({required Participation participation});

  Future<Unit> deleteParticipationById({required String id});

  Future<Participation> getParticipationById({required String id});

  Future<Participation> getParticipationByContestIdAndParticipantId({
    required String contestId,
    required String participantId,
  });

  Future<List<Participation>> getParticipationsByContestId({required String contestId});

  Future<List<Participation>> getParticipationsByParticipantId({required String participantId});
}

//* Implementation
class ParticipationServiceImpl implements ParticipationService {
  final SupabaseClient _supabase;

  ParticipationServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Participation> createParticipation({required Participation participation}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'create_participation', params: participation.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'Participation creation failed');
      }
      return Participation.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Participation> updateParticipation({required Participation participation}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'update_participation',
          params: participation.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'Participation update failed');
      }
      return Participation.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteParticipationById({required String id}) async {
    try {
      await _supabase.rpc('delete_participation_by_id', params: {'p_id': id});
      return unit;
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Participation> getParticipationById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_participation_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        throw SafeException(message: 'No Participation found');
      }
      return Participation.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Participation> getParticipationByContestIdAndParticipantId(
      {required String contestId, required String participantId}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_participation_by_contest_id_and_participant_id',
          params: {'p_contest_id': contestId, 'p_participant_id': participantId});
      if (res.isEmpty) {
        throw SafeException(message: 'No Participation found');
      }
      return Participation.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Participation>> getParticipationsByContestId({required String contestId}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_participations_by_contest_id',
          params: {'p_contest_id': contestId});
      return res.map((e) => Participation.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Participation>> getParticipationsByParticipantId(
      {required String participantId}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_participations_by_participant_id',
          params: {'p_participant_id': participantId});
      return res.map((e) => Participation.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}