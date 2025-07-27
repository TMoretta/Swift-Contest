import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/simple_juror_vote.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class SimpleJurorVoteDao implements Dao<SimpleJurorVote> {}

class SimpleJurorVoteDaoImpl implements SimpleJurorVoteDao {
  final SupabaseClient _supabase;

  SimpleJurorVoteDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, SimpleJurorVote>> create({required SimpleJurorVote entity}) async {
    try {
      final res = await _supabase.from('simple_juror_votes').insert(entity.toJson()).select().single();
      return right(SimpleJurorVote.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVote>> update({required SimpleJurorVote entity}) async {
    try {
      final res = await _supabase.from('simple_juror_votes').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(SimpleJurorVote.fromJson(res));
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
      await _supabase.from('simple_juror_votes').delete().eq('id', id);
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
  Future<Either<Failure, SimpleJurorVote>> getById({required String id}) async {
    try {
      final res = await _supabase.from('simple_juror_votes').select().eq('id', id).limit(1).single();
      return right(SimpleJurorVote.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVote?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('simple_juror_votes').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? SimpleJurorVote.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<SimpleJurorVote>>> getAll() async {
    try {
      final res = await _supabase.from('simple_juror_votes').select();
      return right(res.map((e) => SimpleJurorVote.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
