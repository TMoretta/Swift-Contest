import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/database/entities/voting_form_submission.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class VotingFormSubmissionDao implements Dao<VotingFormSubmission> {}

class VotingFormSubmissionDaoImpl implements VotingFormSubmissionDao {
  final SupabaseClient _supabase;

  VotingFormSubmissionDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingFormSubmission>> create({required VotingFormSubmission entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_form_submissions').insert(entity.toJson()).select().single();
      return Either.right(VotingFormSubmission.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingFormSubmission>> update({required VotingFormSubmission entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_form_submissions').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(VotingFormSubmission.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('voting_form_submissions').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, VotingFormSubmission>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_form_submissions').select().eq('id', id).limit(1).single();
      return Either.right(VotingFormSubmission.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingFormSubmission?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_form_submissions').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? VotingFormSubmission.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<VotingFormSubmission>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_form_submissions').select();
      return Either.right(res.map((e) => VotingFormSubmission.fromJson(e)).toList(growable: false));
    });
  }
}
