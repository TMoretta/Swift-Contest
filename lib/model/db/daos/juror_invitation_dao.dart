import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/juror_invitation.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class JurorInvitationDao implements Dao<JurorInvitation> {}

class JurorInvitationDaoImpl implements JurorInvitationDao {
  final SupabaseClient _supabase;

  JurorInvitationDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, JurorInvitation>> create({required JurorInvitation entity}) async {
    try {
      final res = await _supabase.from('juror_invitations').insert(entity.toJson()).select().single();
      return right(JurorInvitation.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, JurorInvitation>> update({required JurorInvitation entity}) async {
    try {
      final res = await _supabase.from('juror_invitations').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(JurorInvitation.fromJson(res));
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
      await _supabase.from('juror_invitations').delete().eq('id', id);
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
  Future<Either<Failure, JurorInvitation>> getById({required String id}) async {
    try {
      final res = await _supabase.from('juror_invitations').select().eq('id', id).limit(1).single();
      return right(JurorInvitation.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, JurorInvitation?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('contests').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? JurorInvitation.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<JurorInvitation>>> getAll() async {
    try {
      final res = await _supabase.from('juror_invitations').select();
      return right(res.map((e) => JurorInvitation.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
