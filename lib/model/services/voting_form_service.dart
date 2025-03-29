import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_form/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form/voting_form_field.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';

abstract interface class VotingFormService {
  Future<VotingForm> getVotingFormById({required String id});

  Future<VotingForm> updateVotingFormById({
    required String id,
    required List<VotingFormField> fields,
  });
}

class VotingFormServiceImpl implements VotingFormService {
  final SupabaseClient _supabase;

  VotingFormServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<VotingForm> getVotingFormById({required String id}) async {
    try {
      final Map<String, dynamic> votingFormMap =
          await _supabase.rpc('get_voting_form_by_id', params: {'p_id': id});
      return VotingForm.fromJson(votingFormMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<VotingForm> updateVotingFormById({
    required String id,
    required List<VotingFormField> fields,
  }) async {
    final List<Map<String, dynamic>> fieldsMaps =
        fields.map((field) => field.toJson()).toList(growable: false);
    try {
      final Map<String, dynamic> votingFormMap = await _supabase.rpc(
        'update_voting_form_by_id',
        params: {
          'p_id' : id,
          'p_fields': fieldsMaps,
        },
      );
      return VotingForm.fromJson(votingFormMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }
}
