import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class VotingFormFieldService {
  Future<VotingFormField> createVotingFormField({required VotingFormField votingFormField});

  Future<VotingFormField> updateVotingFormFieldById({required String id, required VotingFormField votingFormField,});

  Future<Unit> deleteVotingFormFieldById({required String id});

  Future<VotingFormField> getVotingFormFieldById({required String id});

  Future<List<VotingFormField>> getVotingFormFieldsByVotingFormId({required String votingFormId});
}

//* Implementation
class VotingFormFieldServiceImpl implements VotingFormFieldService {
  final SupabaseClient _supabase;

  VotingFormFieldServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<VotingFormField> createVotingFormField({required VotingFormField votingFormField}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('voting_form_fields').insert(votingFormField.toJson()).select();
      return VotingFormField.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingFormField> updateVotingFormFieldById(
      {required String id, required VotingFormField votingFormField,}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_form_fields')
          .update(votingFormField.toJson())
          .eq('id', id)
          .select();
      return VotingFormField.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteVotingFormFieldById({required String id}) async {
    try {
      await _supabase.from('voting_form_fields').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingFormField> getVotingFormFieldById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
      await _supabase.from('voting_form_fields').select().eq('id', id);
      return VotingFormField.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<VotingFormField>> getVotingFormFieldsByVotingFormId(
      {required String votingFormId}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('voting_form_fields').select().eq('voting_form_id', votingFormId);
      return results.map((e) => VotingFormField.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }


}
