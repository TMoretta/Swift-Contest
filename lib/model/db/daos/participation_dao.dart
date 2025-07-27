import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/db/entities/participation.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class ParticipationDao implements Dao<Participation> {
  Future<Either<Failure, List<Participation>>> getByContestId({required String contestId});

  Future<Either<Failure,Unit>> deleteByContestIdAndParticipantId({required String contestId, required String participantId});

  Future<Either<Failure,Participation>> getByContestIdAndParticipantId({required String contestId, required String participantId});
}

class ParticipationDaoImpl implements ParticipationDao {
  final SupabaseClient _supabase;

  ParticipationDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Participation>> create({required Participation entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('participations').insert(entity.toJson()).select().single();
      return Either.right(Participation.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Participation>> update({required Participation entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('participations').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(Participation.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('participations').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, Participation>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('participations').select().eq('id', id).limit(1).single();
      return Either.right(Participation.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Participation?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('participations').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? Participation.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<Participation>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('participations').select();
      return Either.right(res.map((e) => Participation.fromJson(e)).toList(growable: false));
    });
  }

  @override
  Future<Either<Failure, List<Participation>>> getByContestId({required String contestId}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('participations').select().eq('contest_id', contestId).order('created_at');
      return Either.right(res.map((e) => Participation.fromJson(e)).toList(growable: false));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteByContestIdAndParticipantId({required String contestId, required String participantId,}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('participations').delete().eq('contest_id', contestId).eq('participant_id', participantId);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, Participation>> getByContestIdAndParticipantId({required String contestId, required String participantId,}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('participations').select().eq('contest_id', contestId).eq('participant_id', participantId).limit(1).single();
      return Either.right(Participation.fromJson(res));
    });
  }
}
