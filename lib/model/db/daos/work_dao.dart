import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/work.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class WorkDao implements Dao<Work> {
  Future<Either<Failure, Work?>> getNullableByParticipationId({required String participationId});

}

class WorkDaoImpl implements WorkDao {
  final SupabaseClient _supabase;

  WorkDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Work>> create({required Work entity}) async {
    try {
      final res = await _supabase.from('works').insert(entity.toJson()).select().single();
      return right(Work.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Work>> update({required Work entity}) async {
    try {
      final res = await _supabase.from('works').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(Work.fromJson(res));
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
      await _supabase.from('works').delete().eq('id', id);
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
  Future<Either<Failure, Work>> getById({required String id}) async {
    try {
      final res = await _supabase.from('works').select().eq('id', id).limit(1).single();
      return right(Work.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Work?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('works').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? Work.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Work>>> getAll() async {
    try {
      final res = await _supabase.from('works').select();
      return right(res.map((e) => Work.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Work?>> getNullableByParticipationId({required String participationId,}) async {
    try {
      final res = await _supabase.from('works').select().eq('participation_id', participationId).limit(1).maybeSingle();
      return right(res != null ? Work.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }

  }
}
