import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/db/entities/voting_session_simple_juror.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class VotingSessionSimpleJurorDao implements Dao<VotingSessionSimpleJuror> {}

class VotingSessionSimpleJurorDaoImpl implements VotingSessionSimpleJurorDao {
  final SupabaseClient _supabase;

  VotingSessionSimpleJurorDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingSessionSimpleJuror>> create({required VotingSessionSimpleJuror entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_simple_jurors').insert(entity.toJson()).select().single();
      return Either.right(VotingSessionSimpleJuror.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingSessionSimpleJuror>> update({required VotingSessionSimpleJuror entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_simple_jurors').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(VotingSessionSimpleJuror.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('voting_session_simple_jurors').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, VotingSessionSimpleJuror>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_simple_jurors').select().eq('id', id).limit(1).single();
      return Either.right(VotingSessionSimpleJuror.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingSessionSimpleJuror?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_simple_jurors').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? VotingSessionSimpleJuror.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<VotingSessionSimpleJuror>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_simple_jurors').select();
      return Either.right(res.map((e) => VotingSessionSimpleJuror.fromJson(e)).toList(growable: false));
    });
  }
}
