import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/database/entities/contest.dart';
import 'package:swift_contest/model/utils/handle_backend_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class ContestDao implements Dao<Contest> {
  Future<Either<Failure, List<Contest>>> getByOrganizerId({required String organizerId});
}

class ContestDaoImpl implements ContestDao {
  final SupabaseClient _supabase;

  ContestDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Contest>> create({required Contest entity}) {
    return handleBackendCall(() async {
      final res = await _supabase.from('contests').insert(entity.toJson()).select().single();
      return Either.right(Contest.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Contest>> update({required Contest entity}) {
    return handleBackendCall(() async {
      final res = await _supabase
          .from('contests')
          .update(entity.toJson())
          .eq('id', entity.id!)
          .select()
          .single();

      return Either.right(Contest.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) {
    return handleBackendCall(() async {
      await _supabase.from('contests').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, Contest>> getById({required String id}) {
    return handleBackendCall(() async {
      final res = await _supabase.from('contests').select().eq('id', id).limit(1).single();
      return Either.right(Contest.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Contest?>> getNullableById({required String id}) {
    return handleBackendCall(() async {
      final res = await _supabase.from('contests').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? Contest.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<Contest>>> getAll() {
    return handleBackendCall(() async {
      final res = await _supabase.from('contests').select().order('created_at');
      return Either.right(res.map((e) => Contest.fromJson(e)).toList(growable: false));
    });
  }

  @override
  Future<Either<Failure, List<Contest>>> getByOrganizerId({required String organizerId}) {
    return handleBackendCall(() async {
      final res = await _supabase
          .from('contests')
          .select()
          .eq('organizer_id', organizerId)
          .order('created_at');
      return Either.right(res.map((e) => Contest.fromJson(e)).toList(growable: false));
    });
  }
}
