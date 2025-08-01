import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/database/entities/voting_session_participant.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class VotingSessionParticipationDao implements Dao<VotingSessionParticipant> {}

class VotingSessionParticipationDaoImpl implements VotingSessionParticipationDao {
  final SupabaseClient _supabase;

  VotingSessionParticipationDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingSessionParticipant>> create({required VotingSessionParticipant entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_participations').insert(entity.toJson()).select().single();
      return Either.right(VotingSessionParticipant.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingSessionParticipant>> update({required VotingSessionParticipant entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_participations').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(VotingSessionParticipant.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('voting_session_participations').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, VotingSessionParticipant>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_participations').select().eq('id', id).limit(1).single();
      return Either.right(VotingSessionParticipant.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingSessionParticipant?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_participations').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? VotingSessionParticipant.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<VotingSessionParticipant>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_participations').select();
      return Either.right(res.map((e) => VotingSessionParticipant.fromJson(e)).toList(growable: false));
    });
  }
}
