import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/place.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class PlaceDao implements Dao<Place> {}

class PlaceDaoImpl implements PlaceDao {
  final SupabaseClient _supabase;

  PlaceDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Place>> create({required Place entity}) async {
    try {
      final res = await _supabase.from('places').insert(entity.toJson()).select().single();
      return right(Place.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Place>> update({required Place entity}) async {
    try {
      final res = await _supabase.from('places').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(Place.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    try {
      await _supabase.from('places').delete().eq('id', id);
      return right(unit);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Place>> getById({required String id}) async {
    try {
      final res = await _supabase.from('places').select().eq('id', id).limit(1).single();
      return right(Place.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Place?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('places').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? Place.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Place>>> getAll() async {
    try {
      final res = await _supabase.from('places').select();
      return right(res.map((e) => Place.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
