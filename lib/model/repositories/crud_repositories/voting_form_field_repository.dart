import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class VotingFormFieldRepository {
  Future<Either<Failure, VotingFormField>> createVotingFormField({
    required VotingFormField votingFormField,
  });

  Future<Either<Failure, VotingFormField>> updateVotingFormField({
    required VotingFormField votingFormField,
  });

  Future<Either<Failure, VotingFormField>> deleteVotingFormFieldById({required String id});

  Future<Either<Failure, VotingFormField?>> getVotingFormFieldById({required String id});

  Future<Either<Failure, List<VotingFormField>>> getVotingFormFieldsByVotingFormId({
    required String votingFormId,
  });
}

//* Implementation
class VotingFormFieldRepositoryImpl implements VotingFormFieldRepository {
  final SupabaseClient _supabase;

  VotingFormFieldRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<Either<Failure, VotingFormField>> createVotingFormField({
    required VotingFormField votingFormField,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('create_voting_form_field', params: {'p_voting_form_field': votingFormField.toJson()});
      return right(VotingFormField.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingFormField>> updateVotingFormField({
    required VotingFormField votingFormField,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('update_voting_form_field', params: {'p_voting_form_field': votingFormField.toJson()});
      return right(VotingFormField.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingFormField>> deleteVotingFormFieldById({required String id}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_voting_form_field_by_id', params: {'p_id': id});
      return right(VotingFormField.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingFormField?>> getVotingFormFieldById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_voting_form_field_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(VotingFormField.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<VotingFormField>>> getVotingFormFieldsByVotingFormId({
    required String votingFormId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_voting_form_fields_by_voting_form_id',
          params: {'p_voting_form_id': votingFormId});
      return right(res.map((e) => VotingFormField.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
