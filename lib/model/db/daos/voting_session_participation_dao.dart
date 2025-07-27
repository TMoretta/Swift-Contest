import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/voting_session_participation.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class VotingSessionParticipationDao implements Dao<VotingSessionParticipation> {}

class VotingSessionParticipationDaoImpl implements VotingSessionParticipationDao {
  final SupabaseClient _supabase;

  VotingSessionParticipationDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingSessionParticipation>> create({required VotingSessionParticipation entity}) async {
    try {
      final res = await _supabase.from('voting_session_participations').insert(entity.toJson()).select().single();
      return right(VotingSessionParticipation.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionParticipation>> update({required VotingSessionParticipation entity}) async {
    try {
      final res = await _supabase.from('voting_session_participations').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(VotingSessionParticipation.fromJson(res));
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
      await _supabase.from('voting_session_participations').delete().eq('id', id);
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
  Future<Either<Failure, VotingSessionParticipation>> getById({required String id}) async {
    try {
      final res = await _supabase.from('voting_session_participations').select().eq('id', id).limit(1).single();
      return right(VotingSessionParticipation.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionParticipation?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('voting_session_participations').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? VotingSessionParticipation.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<VotingSessionParticipation>>> getAll() async {
    try {
      final res = await _supabase.from('voting_session_participations').select();
      return right(res.map((e) => VotingSessionParticipation.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
