import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class PlaceRepository {
  Future<Either<Failure, Place>> createPlace({required Place place});

  Future<Either<Failure, Place>> updatePlace({required Place place});

  Future<Either<Failure, Place>> deletePlaceById({required String id});

  Future<Either<Failure, Place?>> getPlaceById({required String id});
}

//* Implementation
class PlaceRepositoryImpl implements PlaceRepository {
  final SupabaseClient _supabase;

  PlaceRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, Place>> createPlace({required Place place}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('create_place', params: {'p_place': place.toJson()});
      return right(Place.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Place>> updatePlace({required Place place}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('update_place', params: {'p_place': place.toJson()});
      return right(Place.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Place>> deletePlaceById({required String id}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_place_by_id', params: {'p_id': id});
      return right(Place.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Place?>> getPlaceById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_place_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(Place.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
