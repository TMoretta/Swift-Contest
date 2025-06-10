import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class VotingFormRepository {
  Future<Either<Failure, VotingForm>> createVotingForm({required VotingForm votingForm});

  Future<Either<Failure, VotingForm>> deleteVotingFormById({required String id});

  Future<Either<Failure, VotingForm?>> getVotingFormById({required String id});
}

//* Implementation
class VotingFormRepositoryImpl implements VotingFormRepository {
  final SupabaseClient _supabase;

  VotingFormRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, VotingForm>> createVotingForm({required VotingForm votingForm}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('create_voting_form', params: {'p_voting_form': votingForm.toJson()});
      return right(VotingForm.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingForm>> deleteVotingFormById({required String id}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_voting_form_by_id', params: {'p_id': id});
      return right(VotingForm.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingForm?>> getVotingFormById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_voting_form_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(VotingForm.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
