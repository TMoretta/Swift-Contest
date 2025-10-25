import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/database/entities/work.dart';
import 'package:swift_contest/model/utils/handle_backend_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class WorkDao implements Dao<Work> {
  Future<Either<Failure, Work?>> getNullableByParticipationId({required String participationId});
}

class WorkDaoImpl implements WorkDao {
  final SupabaseClient _supabase;

  WorkDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Work>> create({required Work entity}) async {
    return handleBackendCall(() async {
      final res = await _supabase.from('works').insert(entity.toJson()).select().single();
      return Either.right(Work.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Work>> update({required Work entity}) async {
    return handleBackendCall(() async {
      final res = await _supabase
          .from('works')
          .update(entity.toJson())
          .eq('id', entity.id!)
          .select()
          .single();
      return Either.right(Work.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleBackendCall(() async {
      await _supabase.from('works').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, Work>> getById({required String id}) async {
    return handleBackendCall(() async {
      final res = await _supabase.from('works').select().eq('id', id).limit(1).single();
      return Either.right(Work.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Work?>> getNullableById({required String id}) async {
    return handleBackendCall(() async {
      final res = await _supabase.from('works').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? Work.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<Work>>> getAll() async {
    return handleBackendCall(() async {
      final res = await _supabase.from('works').select();
      return Either.right(res.map((e) => Work.fromJson(e)).toList(growable: false));
    });
  }

  @override
  Future<Either<Failure, Work?>> getNullableByParticipationId({
    required String participationId,
  }) async {
    return handleBackendCall(() async {
      final res = await _supabase
          .from('works')
          .select()
          .eq('participation_id', participationId)
          .limit(1)
          .maybeSingle();
      return Either.right(res != null ? Work.fromJson(res) : null);
    });
  }
}
