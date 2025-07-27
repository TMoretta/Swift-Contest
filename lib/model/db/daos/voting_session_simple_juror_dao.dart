import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/voting_session_simple_juror.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class VotingSessionSimpleJurorDao implements Dao<VotingSessionSimpleJuror> {}

class VotingSessionSimpleJurorDaoImpl implements VotingSessionSimpleJurorDao {
  final SupabaseClient _supabase;

  VotingSessionSimpleJurorDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingSessionSimpleJuror>> create({required VotingSessionSimpleJuror entity}) async {
    try {
      final res = await _supabase.from('voting_session_simple_jurors').insert(entity.toJson()).select().single();
      return right(VotingSessionSimpleJuror.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionSimpleJuror>> update({required VotingSessionSimpleJuror entity}) async {
    try {
      final res = await _supabase.from('voting_session_simple_jurors').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(VotingSessionSimpleJuror.fromJson(res));
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
      await _supabase.from('voting_session_simple_jurors').delete().eq('id', id);
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
  Future<Either<Failure, VotingSessionSimpleJuror>> getById({required String id}) async {
    try {
      final res = await _supabase.from('voting_session_simple_jurors').select().eq('id', id).limit(1).single();
      return right(VotingSessionSimpleJuror.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionSimpleJuror?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('voting_session_simple_jurors').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? VotingSessionSimpleJuror.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<VotingSessionSimpleJuror>>> getAll() async {
    try {
      final res = await _supabase.from('voting_session_simple_jurors').select();
      return right(res.map((e) => VotingSessionSimpleJuror.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
