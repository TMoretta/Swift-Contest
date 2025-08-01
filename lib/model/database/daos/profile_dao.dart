import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/database/entities/profile.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class ProfileDao implements Dao<Profile> {
}

class ProfileDaoImpl implements ProfileDao {
  final SupabaseClient _supabase;

  ProfileDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Profile>> create({required Profile entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('profiles').insert(entity.toJson()).select().single();
      return Either.right(Profile.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Profile>> update({required Profile entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('profiles').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(Profile.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('profiles').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, Profile>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('profiles').select().eq('id', id).limit(1).single();
      return Either.right(Profile.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Profile?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('profiles').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? Profile.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<Profile>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('profiles').select();
      return Either.right(res.map((e) => Profile.fromJson(e)).toList(growable: false));
    });
  }
}
