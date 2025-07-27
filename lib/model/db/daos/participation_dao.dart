import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/participation.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class ParticipationDao implements Dao<Participation> {
  Future<Either<Failure, List<Participation>>> getByContestId({required String contestId});

  Future<Either<Failure,Unit>> deleteByContestIdAndParticipantId({required String contestId, required String participantId});

  Future<Either<Failure,Participation>> getByContestIdAndParticipantId({required String contestId, required String participantId});
}

class ParticipationDaoImpl implements ParticipationDao {
  final SupabaseClient _supabase;

  ParticipationDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Participation>> create({required Participation entity}) async {
    try {
      final res = await _supabase.from('participations').insert(entity.toJson()).select().single();
      return right(Participation.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Participation>> update({required Participation entity}) async {
    try {
      final res = await _supabase.from('participations').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(Participation.fromJson(res));
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
      await _supabase.from('participations').delete().eq('id', id);
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
  Future<Either<Failure, Participation>> getById({required String id}) async {
    try {
      final res = await _supabase.from('participations').select().eq('id', id).limit(1).single();
      return right(Participation.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Participation?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('participations').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? Participation.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Participation>>> getAll() async {
    try {
      final res = await _supabase.from('participations').select();
      return right(res.map((e) => Participation.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Participation>>> getByContestId({required String contestId}) async {
    try {
      final res = await _supabase.from('participations').select().eq('contest_id', contestId).order('created_at');
      return right(res.map((e) => Participation.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteByContestIdAndParticipantId({required String contestId, required String participantId,}) async {
    try {
      await _supabase.from('participations').delete().eq('contest_id', contestId).eq('participant_id', participantId);
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
  Future<Either<Failure, Participation>> getByContestIdAndParticipantId({required String contestId, required String participantId,}) async {
    try {
      final res = await _supabase.from('participations').select().eq('contest_id', contestId).eq('participant_id', participantId).limit(1).single();
      return right(Participation.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }

  }
}
