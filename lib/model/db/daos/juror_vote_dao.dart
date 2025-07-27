import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/juror_vote.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class JurorVoteDao implements Dao<JurorVote> {}

class JurorVoteDaoImpl implements JurorVoteDao {
  final SupabaseClient _supabase;

  JurorVoteDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, JurorVote>> create({required JurorVote entity}) async {
    try {
      final res = await _supabase.from('juror_votes').insert(entity.toJson()).select().single();
      return right(JurorVote.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, JurorVote>> update({required JurorVote entity}) async {
    try {
      final res = await _supabase.from('juror_votes').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(JurorVote.fromJson(res));
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
      await _supabase.from('juror_votes').delete().eq('id', id);
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
  Future<Either<Failure, JurorVote>> getById({required String id}) async {
    try {
      final res = await _supabase.from('juror_votes').select().eq('id', id).limit(1).single();
      return right(JurorVote.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, JurorVote?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('juror_votes').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? JurorVote.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<JurorVote>>> getAll() async {
    try {
      final res = await _supabase.from('juror_votes').select();
      return right(res.map((e) => JurorVote.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
