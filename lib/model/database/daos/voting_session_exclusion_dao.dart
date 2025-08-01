import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/database/entities/voting_session_exclusion.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class VotingSessionExclusionDao implements Dao<VotingSessionExclusion> {}

class VotingSessionExclusionDaoImpl implements VotingSessionExclusionDao {
  final SupabaseClient _supabase;

  VotingSessionExclusionDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingSessionExclusion>> create({required VotingSessionExclusion entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_exclusions').insert(entity.toJson()).select().single();
      return Either.right(VotingSessionExclusion.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingSessionExclusion>> update({required VotingSessionExclusion entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_exclusions').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(VotingSessionExclusion.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('voting_session_exclusions').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, VotingSessionExclusion>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_exclusions').select().eq('id', id).limit(1).single();
      return Either.right(VotingSessionExclusion.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingSessionExclusion?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_exclusions').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? VotingSessionExclusion.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<VotingSessionExclusion>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_exclusions').select();
      return Either.right(res.map((e) => VotingSessionExclusion.fromJson(e)).toList(growable: false));
    });
  }
}
