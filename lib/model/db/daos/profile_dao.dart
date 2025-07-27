import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/profile.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class ProfileDao implements Dao<Profile> {
}

class ProfileDaoImpl implements ProfileDao {
  final SupabaseClient _supabase;

  ProfileDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Profile>> create({required Profile entity}) async {
    try {
      final res = await _supabase.from('profiles').insert(entity.toJson()).select().single();
      return right(Profile.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Profile>> update({required Profile entity}) async {
    try {
      final res = await _supabase.from('profiles').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(Profile.fromJson(res));
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
      await _supabase.from('profiles').delete().eq('id', id);
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
  Future<Either<Failure, Profile>> getById({required String id}) async {
    try {
      final res = await _supabase.from('profiles').select().eq('id', id).limit(1).single();
      return right(Profile.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Profile?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('profiles').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? Profile.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> getAll() async {
    try {
      final res = await _supabase.from('profiles').select();
      return right(res.map((e) => Profile.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
