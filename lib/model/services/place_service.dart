import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class PlaceService {
  Future<Place> createPlace({required Place place});

  Future<Place> updatePlace({required Place place});

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
      final List<Map<String, dynamic>> res =
      await _supabase.rpc('create_place', params: place.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'Place creation failed');
      }
      return Place.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Place> updatePlace({required Place place}) async {
    try {
      final List<Map<String, dynamic>> res =
      await _supabase.rpc('update_place', params: place.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'Place update failed');
      }
      return Place.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deletePlaceById({required String id}) async {
    try {
      await _supabase.rpc('delete_place_by_id', params: {'p_id': id});
      return unit;
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Place> getPlaceById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
      await _supabase.rpc('get_place_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        throw SafeException(message: 'No Place found');
      }
      return Place.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}