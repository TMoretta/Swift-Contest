import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class ParticipationService {
  Future<Participation> createParticipation({required Participation participation});

  Future<Participation> updateParticipationById(
      {required String id, required Participation participation});

  // Future<Participation> updateParticipationByContestIdAndParticipantId({
  //   required String contestId,
  //   required String participantId,
  //   required Participation participation,
  // });

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
      final List<Map<String, dynamic>> results =
          await _supabase.from('participations').insert(participation.toJson()).select();
      return Participation.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Participation> updateParticipationById({
    required String id,
    required Participation participation,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('participations')
          .update(participation.toJson())
          .eq('id', id)
          .select();
      return Participation.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  // @override
  // Future<Participation> updateParticipationByContestIdAndParticipantId({
  //   required String contestId,
  //   required String participantId,
  //   required Participation participation,
  // }) async {
  //   try {
  //     final List<Map<String, dynamic>> results = await _supabase
  //         .from('participations')
  //         .update(participation.toJson())
  //         .eq('contest_id', contestId)
  //         .eq('participant_id', participantId)
  //         .select();
  //     return Participation.fromJson(results[0]);
  //   } catch (e) {
  //     throw CustomException(message: e.toString());
  //   }
  // }

  @override
  Future<Unit> deleteParticipationById({required String id}) async {
    try {
      await _supabase.from('participations').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Participation> getParticipationById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('participations').select().eq('id', id);
      return Participation.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Participation> getParticipationByContestIdAndParticipantId(
      {required String contestId, required String participantId}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('participations')
          .select()
          .eq('contest_id', contestId)
          .eq('participant_id', participantId);
      return Participation.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Participation>> getParticipationsByContestId({required String contestId}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('participations').select().eq('contest_id', contestId);
      return results.map((e) => Participation.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Participation>> getParticipationsByParticipantId(
      {required String participantId}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('participations').select().eq('participant_id', participantId);
      return results.map((e) => Participation.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
