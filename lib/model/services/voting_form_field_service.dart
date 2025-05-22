import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class VotingFormFieldService {
  Future<VotingFormField> createVotingFormField({
    required VotingFormField votingFormField,
  });

  Future<VotingFormField> updateVotingFormField({
    required VotingFormField votingFormField,
  });

  Future<Unit> deleteVotingFormFieldById({required String id});

  Future<VotingFormField> getVotingFormFieldById({required String id});

  Future<List<VotingFormField>> getVotingFormFieldsByVotingFormId({
    required String votingFormId,
  });
}

//* Implementation
class VotingFormFieldServiceImpl implements VotingFormFieldService {
  final SupabaseClient _supabase;

  VotingFormFieldServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<VotingFormField> createVotingFormField({
    required VotingFormField votingFormField,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'create_voting_form_field',
          params: votingFormField.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'VotingFormField creation failed');
      }
      return VotingFormField.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingFormField> updateVotingFormField({
    required VotingFormField votingFormField,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'update_voting_form_field',
          params: votingFormField.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'VotingFormField update failed');
      }
      return VotingFormField.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteVotingFormFieldById({required String id}) async {
    try {
      await _supabase
          .rpc('delete_voting_form_field_by_id', params: {'p_id': id});
      return unit;
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingFormField> getVotingFormFieldById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_form_field_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        throw SafeException(message: 'No VotingFormField found');
      }
      return VotingFormField.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<VotingFormField>> getVotingFormFieldsByVotingFormId({
    required String votingFormId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_form_fields_by_voting_form_id',
          params: {'p_voting_form_id': votingFormId});
      return res
          .map((e) => VotingFormField.fromJson(e))
          .toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}