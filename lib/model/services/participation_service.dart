import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/participation/participation.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';

//* Interface
abstract interface class ParticipationService {
  Future<Participation> createParticipation({
    required String contestId,
    required String participantId,
    required String inviteEmail,
    required String workId,
  });

  Future<Participation> createParticipationInvite({
    required String contestId,
    required String inviteEmail,
  });

  Future<List<Participation>> getAllParticipations();

  Future<Participation> getParticipationById({required String id});

  Future<List<Participation>> getParticipationsByContestId({required String contestId});

  Future<List<Participation>> getParticipationsByParticipantId({
    required String participantId,
  });

  Future<Participation> getParticipationByContestIdAndParticipantId({
    required String contestId,
    required String participantId,
  });

  Future<Participation> updateParticipationById({
    required String id,
    String? contestId,
    String? participantId,
    String? inviteEmail,
    String? workId,
  });

  Future<Unit> deleteParticipationById({required String id});

  Future<Participation> joinContestAsParticipant({
    required String participantId,
    required String contestToken,
    required String participantToken,
  });
}

//* Implementation
class ParticipationServiceImpl implements ParticipationService {
  final SupabaseClient _supabase;

  ParticipationServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Participation> createParticipation({
    required String contestId,
    required String participantId,
    required String inviteEmail,
    required String workId,
  }) async {
    try {
      final Map<String, dynamic> contestParticipantMap =
          await _supabase.rpc('create_participation', params: {
        'p_contest_id': contestId,
        'p_participant_id': participantId,
        'p_invite_email': inviteEmail,
        'p_work_id': workId,
      });
      return Participation.fromJson(contestParticipantMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Participation> createParticipationInvite({
    required String contestId,
    required String inviteEmail,
  }) async {
    try {
      final Map<String, dynamic> contestParticipantMap =
          await _supabase.rpc('create_participation_invite', params: {
        'p_contest_id': contestId,
        'p_invite_email': inviteEmail,
      });
      return Participation.fromJson(contestParticipantMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<List<Participation>> getAllParticipations() async {
    try {
      final List<Map<String, dynamic>> contestsParticipantsMaps =
          await _supabase.rpc('get_all_participations');
      return contestsParticipantsMaps
          .map((contestParticipantMap) => Participation.fromJson(contestParticipantMap))
          .toList(growable: false);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Participation> getParticipationById({required String id}) async {
    try {
      final Map<String, dynamic> contestParticipantMap =
          await _supabase.rpc('get_participation_by_id', params: {'p_id': id});
      return Participation.fromJson(contestParticipantMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<List<Participation>> getParticipationsByContestId({
    required String contestId,
  }) async {
    try {
      final List<Map<String, dynamic>> contestsParticipantsMaps = await _supabase
          .rpc('get_participations_by_contest_id', params: {'p_contest_id': contestId});
      return contestsParticipantsMaps
          .map((contestParticipantMap) => Participation.fromJson(contestParticipantMap))
          .toList(growable: false);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<List<Participation>> getParticipationsByParticipantId(
      {required String participantId}) async {
    try {
      final List<Map<String, dynamic>> contestsParticipantsMaps = await _supabase
          .rpc('get_participations_by_participant_id', params: {'p_participant_id': participantId});
      return contestsParticipantsMaps
          .map((contestParticipantMap) => Participation.fromJson(contestParticipantMap))
          .toList(growable: false);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Participation> getParticipationByContestIdAndParticipantId({
    required String contestId,
    required String participantId,
  }) async {
    try {
      final Map<String, dynamic> participationMap =
      await _supabase.rpc('get_participation_by_contest_id_and_participant_id', params: {'p_contest_id':contestId, 'p_participant_id': participantId});
      return Participation.fromJson(participationMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Participation> updateParticipationById({
    required String id,
    String? contestId,
    String? participantId,
    String? inviteEmail,
    String? workId,
  }) async {
    try {
      final Map<String, dynamic> contestParticipantMap =
          await _supabase.rpc('update_participation_by_id', params: {
        'p_id': id,
        'p_contest_id': contestId,
        'p_participant_id': participantId,
        'p_invite_email': inviteEmail,
        'work_id': workId,
      });
      return Participation.fromJson(contestParticipantMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteParticipationById({required String id}) async {
    try {
      await _supabase.rpc('delete_participation_by_id', params: {'p_id': id});
      return unit;
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Participation> joinContestAsParticipant({
    required String participantId,
    required String contestToken,
    required String participantToken,
  }) async {
    try {
      final Map<String, dynamic> map = await _supabase.rpc('join_contest_as_participant', params: {
        'p_participant_id': participantId,
        'p_contest_token': contestToken,
        'p_participant_token': participantToken,
      });
      return Participation.fromJson(map);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }
}
