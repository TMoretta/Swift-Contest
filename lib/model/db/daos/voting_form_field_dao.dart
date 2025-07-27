import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/voting_form_field.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class VotingFormFieldDao implements Dao<VotingFormField> {
  Future<Either<Failure,Unit>> deleteByVotingFormId({required String votingFormId});
}

class VotingFormFieldDaoImpl implements VotingFormFieldDao {
  final SupabaseClient _supabase;

  VotingFormFieldDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingFormField>> create({required VotingFormField entity}) async {
    try {
      final res = await _supabase.from('voting_form_fields').insert(entity.toJson()).select().single();
      return right(VotingFormField.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingFormField>> update({required VotingFormField entity}) async {
    try {
      final res = await _supabase.from('voting_form_fields').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(VotingFormField.fromJson(res));
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
      await _supabase.from('voting_form_fields').delete().eq('id', id);
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
  Future<Either<Failure, VotingFormField>> getById({required String id}) async {
    try {
      final res = await _supabase.from('voting_form_fields').select().eq('id', id).limit(1).single();
      return right(VotingFormField.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingFormField?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('voting_form_fields').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? VotingFormField.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<VotingFormField>>> getAll() async {
    try {
      final res = await _supabase.from('voting_form_fields').select();
      return right(res.map((e) => VotingFormField.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteByVotingFormId({required String votingFormId}) async {
    try {
      await _supabase.from('voting_form_fields').delete().eq('voting_form_id', votingFormId);
      return right(unit);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
