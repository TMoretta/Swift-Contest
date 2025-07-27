import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/voting_session.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class VotingSessionDao implements Dao<VotingSession> {

Future<Either<Failure, List<VotingSession>>> getByContestId({required String contestId});
}

class VotingSessionDaoImpl implements VotingSessionDao {
  final SupabaseClient _supabase;

  VotingSessionDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingSession>> create({required VotingSession entity}) async {
    try {
      final res = await _supabase.from('voting_sessions').insert(entity.toJson()).select().single();
      return right(VotingSession.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSession>> update({required VotingSession entity}) async {
    try {
      final res = await _supabase.from('voting_sessions').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(VotingSession.fromJson(res));
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
      await _supabase.from('voting_sessions').delete().eq('id', id);
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
  Future<Either<Failure, VotingSession>> getById({required String id}) async {
    try {
      final res = await _supabase.from('voting_sessions').select().eq('id', id).limit(1).single();
      return right(VotingSession.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSession?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('voting_sessions').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? VotingSession.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<VotingSession>>> getAll() async {
    try {
      final res = await _supabase.from('voting_sessions').select();
      return right(res.map((e) => VotingSession.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<VotingSession>>> getByContestId({required String contestId})async {
    try {
      final res = await _supabase.from('voting_sessions').select().eq('contest_id', contestId);
      return right(res.map((e) => VotingSession.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
