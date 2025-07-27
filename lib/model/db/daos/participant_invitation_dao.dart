import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/participant_invitation.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class ParticipantInvitationDao implements Dao<ParticipantInvitation> {}

class ParticipantInvitationDaoImpl implements ParticipantInvitationDao {
  final SupabaseClient _supabase;

  ParticipantInvitationDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, ParticipantInvitation>> create({required ParticipantInvitation entity}) async {
    try {
      final res = await _supabase.from('participant_invitations').insert(entity.toJson()).select().single();
      return right(ParticipantInvitation.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, ParticipantInvitation>> update({required ParticipantInvitation entity}) async {
    try {
      final res = await _supabase.from('participant_invitations').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(ParticipantInvitation.fromJson(res));
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
      await _supabase.from('participant_invitations').delete().eq('id', id);
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
  Future<Either<Failure, ParticipantInvitation>> getById({required String id}) async {
    try {
      final res = await _supabase.from('participant_invitations').select().eq('id', id).limit(1).single();
      return right(ParticipantInvitation.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, ParticipantInvitation?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('participant_invitations').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? ParticipantInvitation.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<ParticipantInvitation>>> getAll() async {
    try {
      final res = await _supabase.from('participant_invitations').select();
      return right(res.map((e) => ParticipantInvitation.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
