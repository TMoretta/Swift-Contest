import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/voting_form.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class VotingFormDao implements Dao<VotingForm> {}

class VotingFormDaoImpl implements VotingFormDao {
  final SupabaseClient _supabase;

  VotingFormDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingForm>> create({required VotingForm entity}) async {
    try {
      final res = await _supabase.from('voting_forms').insert(entity.toJson()).select().single();
      return right(VotingForm.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingForm>> update({required VotingForm entity}) async {
    try {
      final res = await _supabase.from('voting_forms').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(VotingForm.fromJson(res));
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
      await _supabase.from('voting_forms').delete().eq('id', id);
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
  Future<Either<Failure, VotingForm>> getById({required String id}) async {
    try {
      final res = await _supabase.from('voting_forms').select().eq('id', id).limit(1).single();
      return right(VotingForm.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingForm?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('voting_forms').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? VotingForm.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<VotingForm>>> getAll() async {
    try {
      final res = await _supabase.from('voting_forms').select();
      return right(res.map((e) => VotingForm.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
