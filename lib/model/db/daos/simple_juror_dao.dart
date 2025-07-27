import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/simple_juror.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class SimpleJurorDao implements Dao<SimpleJuror> {}

class SimpleJurorDaoImpl implements SimpleJurorDao {
  final SupabaseClient _supabase;

  SimpleJurorDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, SimpleJuror>> create({required SimpleJuror entity}) async {
    try {
      final res = await _supabase.from('simple_jurors').insert(entity.toJson()).select().single();
      return right(SimpleJuror.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJuror>> update({required SimpleJuror entity}) async {
    try {
      final res = await _supabase.from('simple_jurors').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(SimpleJuror.fromJson(res));
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
      await _supabase.from('simple_jurors').delete().eq('id', id);
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
  Future<Either<Failure, SimpleJuror>> getById({required String id}) async {
    try {
      final res = await _supabase.from('simple_jurors').select().eq('id', id).limit(1).single();
      return right(SimpleJuror.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJuror?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('simple_jurors').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? SimpleJuror.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<SimpleJuror>>> getAll() async {
    try {
      final res = await _supabase.from('simple_jurors').select();
      return right(res.map((e) => SimpleJuror.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
