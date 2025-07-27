import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/db/entities/voting_form_field.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class VotingFormFieldDao implements Dao<VotingFormField> {
  Future<Either<Failure,Unit>> deleteByVotingFormId({required String votingFormId});
}

class VotingFormFieldDaoImpl implements VotingFormFieldDao {
  final SupabaseClient _supabase;

  VotingFormFieldDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingFormField>> create({required VotingFormField entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_form_fields').insert(entity.toJson()).select().single();
      return Either.right(VotingFormField.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingFormField>> update({required VotingFormField entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_form_fields').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(VotingFormField.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('voting_form_fields').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, VotingFormField>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_form_fields').select().eq('id', id).limit(1).single();
      return Either.right(VotingFormField.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingFormField?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_form_fields').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? VotingFormField.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<VotingFormField>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_form_fields').select();
      return Either.right(res.map((e) => VotingFormField.fromJson(e)).toList(growable: false));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteByVotingFormId({required String votingFormId}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('voting_form_fields').delete().eq('voting_form_id', votingFormId);
      return Either.right(unit);
    });
  }
}
