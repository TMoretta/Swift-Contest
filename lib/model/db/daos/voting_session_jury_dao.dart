import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/entities/voting_session_jury.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class VotingSessionJuryDao implements Dao<VotingSessionJury> {}

class VotingSessionJuryDaoImpl implements VotingSessionJuryDao {
  final SupabaseClient _supabase;

  VotingSessionJuryDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingSessionJury>> create({required VotingSessionJury entity}) {
    return handleDatabaseCall(() async {
      final res =
          await _supabase.from('voting_session_juries').insert(entity.toJson()).select().single();
      return Either.right(VotingSessionJury.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingSessionJury>> update({required VotingSessionJury entity}) {
    return handleDatabaseCall(() async {
      final res = await _supabase
          .from('voting_session_juries')
          .update(entity.toJson())
          .eq('id', entity.id!)
          .select()
          .single();

      return Either.right(VotingSessionJury.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) {
    return handleDatabaseCall(() async {
      await _supabase.from('voting_session_juries').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, VotingSessionJury>> getById({required String id}) {
    return handleDatabaseCall(() async {
      final res =
          await _supabase.from('voting_session_juries').select().eq('id', id).limit(1).single();
      return Either.right(VotingSessionJury.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingSessionJury?>> getNullableById({required String id}) {
    return handleDatabaseCall(() async {
      final res = await _supabase
          .from('voting_session_juries')
          .select()
          .eq('id', id)
          .limit(1)
          .maybeSingle();
      return Either.right(res != null ? VotingSessionJury.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<VotingSessionJury>>> getAll() {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_juries').select().order('created_at');
      return Either.right(res.map((e) => VotingSessionJury.fromJson(e)).toList(growable: false));
    });
  }
}
