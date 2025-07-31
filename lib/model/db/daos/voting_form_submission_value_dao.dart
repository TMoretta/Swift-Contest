import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/entities/voting_form_submission_values.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/db/entities/place.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class VotingFormSubmissionValueDao implements Dao<VotingFormSubmissionValue> {}

class VotingFormSubmissionValueDaoImpl implements VotingFormSubmissionValueDao {
  final SupabaseClient _supabase;

  VotingFormSubmissionValueDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingFormSubmissionValue>> create({required VotingFormSubmissionValue entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_form_submission_values').insert(entity.toJson()).select().single();
      return Either.right(VotingFormSubmissionValue.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingFormSubmissionValue>> update({required VotingFormSubmissionValue entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_form_submission_values').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(VotingFormSubmissionValue.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('voting_form_submission_values').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, VotingFormSubmissionValue>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_form_submission_values').select().eq('id', id).limit(1).single();
      return Either.right(VotingFormSubmissionValue.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingFormSubmissionValue?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_form_submission_values').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? VotingFormSubmissionValue.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<VotingFormSubmissionValue>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_form_submission_values').select();
      return Either.right(res.map((e) => VotingFormSubmissionValue.fromJson(e)).toList(growable: false));
    });
  }
}
