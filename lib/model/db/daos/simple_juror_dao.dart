import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/db/entities/simple_juror.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class SimpleJurorDao implements Dao<SimpleJuror> {}

class SimpleJurorDaoImpl implements SimpleJurorDao {
  final SupabaseClient _supabase;

  SimpleJurorDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, SimpleJuror>> create({required SimpleJuror entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('simple_jurors').insert(entity.toJson()).select().single();
      return Either.right(SimpleJuror.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, SimpleJuror>> update({required SimpleJuror entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('simple_jurors').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(SimpleJuror.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('simple_jurors').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, SimpleJuror>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('simple_jurors').select().eq('id', id).limit(1).single();
      return Either.right(SimpleJuror.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, SimpleJuror?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('simple_jurors').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? SimpleJuror.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<SimpleJuror>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('simple_jurors').select();
      return Either.right(res.map((e) => SimpleJuror.fromJson(e)).toList(growable: false));
    });
  }
}
