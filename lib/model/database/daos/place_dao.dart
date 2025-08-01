import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/database/entities/place.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class PlaceDao implements Dao<Place> {}

class PlaceDaoImpl implements PlaceDao {
  final SupabaseClient _supabase;

  PlaceDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Place>> create({required Place entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('places').insert(entity.toJson()).select().single();
      return Either.right(Place.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Place>> update({required Place entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('places').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(Place.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('places').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, Place>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('places').select().eq('id', id).limit(1).single();
      return Either.right(Place.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Place?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('places').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? Place.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<Place>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('places').select();
      return Either.right(res.map((e) => Place.fromJson(e)).toList(growable: false));
    });
  }
}
