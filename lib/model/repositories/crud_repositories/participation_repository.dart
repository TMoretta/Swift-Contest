import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class ParticipationRepository {
  Future<Either<Failure, Participation>> createParticipation({
    required Participation participation,
  });

  Future<Either<Failure, Participation>> updateParticipation({
    required Participation participation,
  });

  Future<Either<Failure, Participation>> deleteParticipationById({
    required String id,
  });

  Future<Either<Failure, Participation?>> getParticipationById({
    required String id,
  });

  Future<Either<Failure, Participation?>> getParticipationByContestIdAndParticipantId({
    required String contestId,
    required String participantId,
  });

  Future<Either<Failure, List<Participation>>> getParticipationsByContestId({
    required String contestId,
  });

  Future<Either<Failure, List<Participation>>> getParticipationsByParticipantId({
    required String participantId,
  });
}

//* Implementation
class ParticipationRepositoryImpl implements ParticipationRepository {
  final SupabaseClient _supabase;

  ParticipationRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<Either<Failure, Participation>> createParticipation({
    required Participation participation,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('create_participation', params: {'p_participation': participation.toJson()});
      return right(Participation.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Participation>> updateParticipation({
    required Participation participation,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('update_participation', params: {'p_participation': participation.toJson()});
      return right(Participation.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Participation>> deleteParticipationById({
    required String id,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_participation_by_id', params: {'p_id': id});
      return right(Participation.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Participation?>> getParticipationById({
    required String id,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_participation_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(Participation.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Participation?>> getParticipationByContestIdAndParticipantId({
    required String contestId,
    required String participantId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_participation_by_contest_id_and_participant_id',
          params: {'p_contest_id': contestId, 'p_participant_id': participantId});
      if (res.isEmpty) {
        return right(null);
      }
      return right(Participation.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Participation>>> getParticipationsByContestId({
    required String contestId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('get_participations_by_contest_id', params: {'p_contest_id': contestId});
      return right(res.map((e) => Participation.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Participation>>> getParticipationsByParticipantId({
    required String participantId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('get_participations_by_participant_id', params: {'p_participant_id': participantId});
      return right(res.map((e) => Participation.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
