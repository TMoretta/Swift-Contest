import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/voting_session_juration.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class VotingSessionJurationDao implements Dao<VotingSessionJuration> {}

class VotingSessionJurationDaoImpl implements VotingSessionJurationDao {
  final SupabaseClient _supabase;

  VotingSessionJurationDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingSessionJuration>> create({required VotingSessionJuration entity}) async {
    try {
      final res = await _supabase.from('voting_session_jurations').insert(entity.toJson()).select().single();
      return right(VotingSessionJuration.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionJuration>> update({required VotingSessionJuration entity}) async {
    try {
      final res = await _supabase.from('voting_session_jurations').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(VotingSessionJuration.fromJson(res));
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
      await _supabase.from('voting_session_jurations').delete().eq('id', id);
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
  Future<Either<Failure, VotingSessionJuration>> getById({required String id}) async {
    try {
      final res = await _supabase.from('voting_session_jurations').select().eq('id', id).limit(1).single();
      return right(VotingSessionJuration.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionJuration?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('voting_session_jurations').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? VotingSessionJuration.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<VotingSessionJuration>>> getAll() async {
    try {
      final res = await _supabase.from('voting_session_jurations').select();
      return right(res.map((e) => VotingSessionJuration.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
