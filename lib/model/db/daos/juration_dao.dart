import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/juration.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class JurationDao implements Dao<Juration> {
  Future<Either<Failure, List<Juration>>> getByContestId({required String contestId});
}

class JurationDaoImpl implements JurationDao {
  final SupabaseClient _supabase;

  JurationDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Juration>> create({required Juration entity}) async {
    try {
      final res = await _supabase.from('jurations').insert(entity.toJson()).select().single();
      return right(Juration.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Juration>> update({required Juration entity}) async {
    try {
      final res = await _supabase.from('jurations').update(entity.toJson()).eq('id', entity.id!!).select().single();
      return right(Juration.fromJson(res));
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
      await _supabase.from('jurations').delete().eq('id', id);
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
  Future<Either<Failure, Juration>> getById({required String id}) async {
    try {
      final res = await _supabase.from('jurations').select().eq('id', id).limit(1).single();
      return right(Juration.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Juration?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('jurations').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? Juration.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Juration>>> getAll() async {
    try {
      final res = await _supabase.from('jurations').select();
      return right(res.map((e) => Juration.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Juration>>> getByContestId({required String contestId}) async {
    try {
      final res = await _supabase.from('participations').select().eq('contest_id', contestId).order('created_at');
      return right(res.map((e) => Juration.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
