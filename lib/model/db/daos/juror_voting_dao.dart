import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/juror_voting.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class JurorVotingDao implements Dao<JurorVoting> {}

class JurorVotingDaoImpl implements JurorVotingDao {
  final SupabaseClient _supabase;

  JurorVotingDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, JurorVoting>> create({required JurorVoting entity}) async {
    try {
      final res = await _supabase.from('juror_votings').insert(entity.toJson()).select().single();
      return right(JurorVoting.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, JurorVoting>> update({required JurorVoting entity}) async {
    try {
      final res = await _supabase.from('juror_votings').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(JurorVoting.fromJson(res));
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
      await _supabase.from('juror_votings').delete().eq('id', id);
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
  Future<Either<Failure, JurorVoting>> getById({required String id}) async {
    try {
      final res = await _supabase.from('juror_votings').select().eq('id', id).limit(1).single();
      return right(JurorVoting.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, JurorVoting?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('juror_votings').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? JurorVoting.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<JurorVoting>>> getAll() async {
    try {
      final res = await _supabase.from('juror_votings').select();
      return right(res.map((e) => JurorVoting.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
