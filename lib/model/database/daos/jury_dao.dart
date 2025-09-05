import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/database/entities/jury.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class JuryDao implements Dao<Jury> {
  Future<Either<Failure, List<Jury>>> getByContestId({required String contestId});
}

class JuryDaoImpl implements JuryDao {
  final SupabaseClient _supabase;

  JuryDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Jury>> create({required Jury entity}) {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('juries').insert(entity.toJson()).select().single();
      return Either.right(Jury.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Jury>> update({required Jury entity}) {
    return handleDatabaseCall(() async {
      final res = await _supabase
          .from('juries')
          .update(entity.toJson())
          .eq('id', entity.id!)
          .select()
          .single();
      return Either.right(Jury.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) {
    return handleDatabaseCall(() async {
      await _supabase.from('juries').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, Jury>> getById({required String id}) {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('juries').select().eq('id', id).limit(1).single();
      return Either.right(Jury.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Jury?>> getNullableById({required String id}) {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('juries').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? Jury.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<Jury>>> getAll() {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('juries').select();
      return Either.right(res.map((e) => Jury.fromJson(e)).toList(growable: false));
    });
  }

  @override
  Future<Either<Failure, List<Jury>>> getByContestId({required String contestId}) {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('juries').select().eq('contest_id', contestId);
      return Either.right(res.map((e) => Jury.fromJson(e)).toList(growable: false));
    });
  }
}
