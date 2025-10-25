import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/database/entities/voting_form.dart';
import 'package:swift_contest/model/utils/handle_backend_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class VotingFormDao implements Dao<VotingForm> {}

class VotingFormDaoImpl implements VotingFormDao {
  final SupabaseClient _supabase;

  VotingFormDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingForm>> create({required VotingForm entity}) async {
    return handleBackendCall(() async {
      final res = await _supabase.from('voting_forms').insert(entity.toJson()).select().single();
      return Either.right(VotingForm.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingForm>> update({required VotingForm entity}) async {
    return handleBackendCall(() async {
      final res = await _supabase.from('voting_forms').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(VotingForm.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleBackendCall(() async {
      await _supabase.from('voting_forms').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, VotingForm>> getById({required String id}) async {
    return handleBackendCall(() async {
      final res = await _supabase.from('voting_forms').select().eq('id', id).limit(1).single();
      return Either.right(VotingForm.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingForm?>> getNullableById({required String id}) async {
    return handleBackendCall(() async {
      final res = await _supabase.from('voting_forms').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? VotingForm.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<VotingForm>>> getAll() async {
    return handleBackendCall(() async {
      final res = await _supabase.from('voting_forms').select();
      return Either.right(res.map((e) => VotingForm.fromJson(e)).toList(growable: false));
    });
  }
}
