import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/voting_session_exclusion.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class VotingSessionExclusionDao implements Dao<VotingSessionExclusion> {}

class VotingSessionExclusionDaoImpl implements VotingSessionExclusionDao {
  final SupabaseClient _supabase;

  VotingSessionExclusionDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingSessionExclusion>> create({required VotingSessionExclusion entity}) async {
    try {
      final res = await _supabase.from('voting_session_exclusions').insert(entity.toJson()).select().single();
      return right(VotingSessionExclusion.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionExclusion>> update({required VotingSessionExclusion entity}) async {
    try {
      final res = await _supabase.from('voting_session_exclusions').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(VotingSessionExclusion.fromJson(res));
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
      await _supabase.from('voting_session_exclusions').delete().eq('id', id);
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
  Future<Either<Failure, VotingSessionExclusion>> getById({required String id}) async {
    try {
      final res = await _supabase.from('voting_session_exclusions').select().eq('id', id).limit(1).single();
      return right(VotingSessionExclusion.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionExclusion?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('voting_session_exclusions').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? VotingSessionExclusion.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<VotingSessionExclusion>>> getAll() async {
    try {
      final res = await _supabase.from('voting_session_exclusions').select();
      return right(res.map((e) => VotingSessionExclusion.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
