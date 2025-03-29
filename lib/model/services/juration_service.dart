import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/juration/juration.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';

//* Interface
abstract interface class JurationService {
  Future<Juration> createJuration({
    required String contestId,
    required String jurorId,
    required String inviteEmail,
  });

  Future<Juration> createJurationInvite({
    required String contestId,
    required String inviteEmail,
  });

  Future<List<Juration>> getAllJurations();

  Future<Juration> getJurationById({required String id});

  Future<List<Juration>> getJurationsByContestId({required String contestId});

  Future<List<Juration>> getJurationsByJurorId({required String jurorId});

  Future<Juration> getJurationByContestIdAndJurorId({
    required String contestId,
    required String jurorId,
  });

  Future<Juration> updateJurationById({
    required String id,
    String? contestId,
    String? jurorId,
    String? inviteEmail,
  });

  Future<Unit> deleteJurationById({required String id});

  Future<Juration> joinContestAsJuror({
    required String jurorId,
    required String contestToken,
    required String jurorToken,
  });
}

//* Implementation
class JurationServiceImpl implements JurationService {
  final SupabaseClient _supabase;

  JurationServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Juration> createJuration({
    required String contestId,
    required String jurorId,
    required String inviteEmail,
  }) async {
    try {
      final Map<String, dynamic> contestJurorMap = await _supabase.rpc('create_juration', params: {
        'p_contest_id': contestId,
        'p_juror_id': jurorId,
        'p_invite_email': inviteEmail,
      });
      return Juration.fromJson(contestJurorMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Juration> createJurationInvite({
    required String contestId,
    required String inviteEmail,
  }) async {
    try {
      final Map<String, dynamic> contestJurorMap =
          await _supabase.rpc('create_juration_invite', params: {
        'p_contest_id': contestId,
        'p_invite_email': inviteEmail,
      });
      return Juration.fromJson(contestJurorMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<List<Juration>> getAllJurations() async {
    try {
      final List<Map<String, dynamic>> contestsJurorsMaps =
          await _supabase.rpc('get_all_jurations');
      return contestsJurorsMaps
          .map((contestJurorMap) => Juration.fromJson(contestJurorMap))
          .toList(growable: false);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Juration> getJurationById({required String id}) async {
    try {
      final Map<String, dynamic> contestJurorMap =
          await _supabase.rpc('get_juration_by_id', params: {'p_id': id});
      return Juration.fromJson(contestJurorMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<List<Juration>> getJurationsByContestId({required String contestId}) async {
    try {
      final List<Map<String, dynamic>> contestsJurorsMaps =
          await _supabase.rpc('get_jurations_by_contest_id', params: {'p_contest_id': contestId});
      return contestsJurorsMaps
          .map((contestJurorMap) => Juration.fromJson(contestJurorMap))
          .toList(growable: false);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<List<Juration>> getJurationsByJurorId({required String jurorId}) async {
    try {
      final List<Map<String, dynamic>> contestsJurorsMaps =
          await _supabase.rpc('get_jurations_by_juror_id', params: {'p_juror_id': jurorId});
      return contestsJurorsMaps
          .map((contestJurorMap) => Juration.fromJson(contestJurorMap))
          .toList(growable: false);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Juration> getJurationByContestIdAndJurorId({
    required String contestId,
    required String jurorId,
  }) async {
    try {
      final Map<String, dynamic> jurationMap =
      await _supabase.rpc('get_juration_by_contest_id_and_juror_id', params: {'p_contest_id':contestId, 'p_juror_id': jurorId});
      return Juration.fromJson(jurationMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Juration> updateJurationById({
    required String id,
    String? contestId,
    String? jurorId,
    String? inviteEmail,
  }) async {
    try {
      final Map<String, dynamic> contestJurorMap =
          await _supabase.rpc('update_juration_by_id', params: {
        'p_id': id,
        'p_contest_id': contestId,
        'p_juror_id': jurorId,
        'p_invite_email': inviteEmail,
      });
      return Juration.fromJson(contestJurorMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteJurationById({required String id}) async {
    try {
      await _supabase.rpc('delete_juration_by_id', params: {'p_id': id});
      return unit;
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Juration> joinContestAsJuror({
    required String jurorId,
    required String contestToken,
    required String jurorToken,
  }) async {
    try {
      final Map<String, dynamic> map = await _supabase.rpc('join_contest_as_juror', params: {
        'p_juror_id': jurorId,
        'p_contest_token': contestToken,
        'p_participant_token': jurorToken,
      });
      return Juration.fromJson(map);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }
}
