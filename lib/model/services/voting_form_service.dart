import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class VotingFormService {
  Future<VotingForm> createVotingForm({required VotingForm votingForm});

  Future<VotingForm> updateVotingFormById({required String id, required VotingForm votingForm});

  Future<Unit> deleteVotingFormById({required String id});

  Future<VotingForm> getVotingFormById({required String id});
}

//* Implementation
class VotingFormServiceImpl implements VotingFormService {
  final SupabaseClient _supabase;

  VotingFormServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<VotingForm> createVotingForm({required VotingForm votingForm}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('voting_forms').insert(votingForm.toJson()).select();
      return VotingForm.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingForm> updateVotingFormById({required String id, required VotingForm votingForm}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('voting_forms')
          .update(votingForm.toJson())
          .eq('id', id)
          .select();
      return VotingForm.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteVotingFormById({required String id}) async {
    try {
      await _supabase.from('voting_forms').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingForm> getVotingFormById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('voting_forms').select().eq('id', id);
      return VotingForm.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
