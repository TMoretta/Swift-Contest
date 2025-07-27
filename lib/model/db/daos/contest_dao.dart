import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/contest.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class ContestDao implements Dao<Contest> {
  Future<Either<Failure, List<Contest>>> getByOrganizerId({required String organizerId});
}

class ContestDaoImpl implements ContestDao {
  final SupabaseClient _supabase;

  ContestDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Contest>> create({required Contest entity}) async {
    try {
      final res = await _supabase.from('contests').insert(entity.toJson()).select().single();
      return right(Contest.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Contest>> update({required Contest entity}) async {
    try {
      final res = await _supabase.from('contests').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(Contest.fromJson(res));
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
      await _supabase.from('contests').delete().eq('id', id);
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
  Future<Either<Failure, Contest>> getById({required String id}) async {
    try {
      final res = await _supabase.from('contests').select().eq('id', id).limit(1).single();
      return right(Contest.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Contest?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('contests').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? Contest.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Contest>>> getAll() async {
    try {
      final res = await _supabase.from('contests').select().order('created_at');
      return right(res.map((e) => Contest.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Contest>>> getByOrganizerId({required String organizerId}) async {
    try {
      final res = await _supabase.from('contests').select().eq('organizer_id', organizerId).order('created_at');
      return right(res.map((e) => Contest.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
