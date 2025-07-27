import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/jury.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class JuryDao implements Dao<Jury> {
  Future<Either<Failure, List<Jury>>> getByContestId({required String contestId});
}

class JuryDaoImpl implements JuryDao {
  final SupabaseClient _supabase;

  JuryDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Jury>> create({required Jury entity}) async {
    try {
      final res = await _supabase.from('juries').insert(entity.toJson()).select().single();
      return right(Jury.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Jury>> update({required Jury entity}) async {
    try {
      final res = await _supabase.from('juries').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(Jury.fromJson(res));
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
      await _supabase.from('juries').delete().eq('id', id);
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
  Future<Either<Failure, Jury>> getById({required String id}) async {
    try {
      final res = await _supabase.from('juries').select().eq('id', id).limit(1).single();
      return right(Jury.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Jury?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('juries').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? Jury.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Jury>>> getAll() async {
    try {
      final res = await _supabase.from('juries').select();
      return right(res.map((e) => Jury.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Jury>>> getByContestId({required String contestId}) async {
    try {
      final res = await _supabase.from('juries').select().eq('contest_id', contestId);
      return right(res.map((e) => Jury.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
