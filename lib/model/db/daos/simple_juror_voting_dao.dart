import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/simple_juror_voting.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class SimpleJurorVotingDao implements Dao<SimpleJurorVoting> {}

class SimpleJurorVotingDaoImpl implements SimpleJurorVotingDao {
  final SupabaseClient _supabase;

  SimpleJurorVotingDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, SimpleJurorVoting>> create({required SimpleJurorVoting entity}) async {
    try {
      final res = await _supabase.from('simple_juror_votings').insert(entity.toJson()).select().single();
      return right(SimpleJurorVoting.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVoting>> update({required SimpleJurorVoting entity}) async {
    try {
      final res = await _supabase.from('simple_juror_votings').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(SimpleJurorVoting.fromJson(res));
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
      await _supabase.from('simple_juror_votings').delete().eq('id', id);
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
  Future<Either<Failure, SimpleJurorVoting>> getById({required String id}) async {
    try {
      final res = await _supabase.from('simple_juror_votings').select().eq('id', id).limit(1).single();
      return right(SimpleJurorVoting.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVoting?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('simple_juror_votings').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? SimpleJurorVoting.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<SimpleJurorVoting>>> getAll() async {
    try {
      final res = await _supabase.from('simple_juror_votings').select();
      return right(res.map((e) => SimpleJurorVoting.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
