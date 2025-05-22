import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class VotingFormService {
  Future<VotingForm> createVotingForm({required VotingForm votingForm});

  Future<VotingForm> updateVotingForm({required VotingForm votingForm});

  Future<Unit> deleteVotingFormById({required String id});

  Future<VotingForm> getVotingFormById({required String id});
}

//* Implementation
class VotingFormServiceImpl implements VotingFormService {
  final SupabaseClient _supabase;

  VotingFormServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<VotingForm> createVotingForm({required VotingForm votingForm}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'create_voting_form', params: votingForm.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'VotingForm creation failed');
      }
      return VotingForm.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingForm> updateVotingForm({required VotingForm votingForm}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'update_voting_form', params: votingForm.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'VotingForm update failed');
      }
      return VotingForm.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteVotingFormById({required String id}) async {
    try {
      await _supabase
          .rpc('delete_voting_form_by_id', params: {'p_id': id});
      return unit;
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<VotingForm> getVotingFormById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('get_voting_form_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        throw SafeException(message: 'No VotingForm found');
      }
      return VotingForm.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}