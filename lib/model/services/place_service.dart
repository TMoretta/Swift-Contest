import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class PlaceService {
  Future<Place> createPlace({required Place place});

  Future<Place> updatePlaceById({required String id, required Place place});

  Future<Unit> deletePlaceById({required String id});

  Future<Place> getPlaceById({required String id});
}

//* Implementation
class PlaceServiceImpl implements PlaceService {
  final SupabaseClient _supabase;

  PlaceServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Place> createPlace({required Place place}) async {
    try {
      final List<Map<String, dynamic>> results =
      await _supabase.from('places').insert(place.toJson()).select();
      return Place.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Place> updatePlaceById({required String id, required Place place}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('places')
          .update(place.toJson())
          .eq('id', id)
          .select();
      return Place.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deletePlaceById({required String id}) async {
    try {
      await _supabase.from('places').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Place> getPlaceById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
      await _supabase.from('places').select().eq('id', id);
      return Place.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
