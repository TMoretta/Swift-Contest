import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/db/entities/voting_session_juration.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class VotingSessionJurationDao implements Dao<VotingSessionJuration> {}

class VotingSessionJurationDaoImpl implements VotingSessionJurationDao {
  final SupabaseClient _supabase;

  VotingSessionJurationDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingSessionJuration>> create({required VotingSessionJuration entity}) {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_jurations').insert(entity.toJson()).select().single();
      return Either.right(VotingSessionJuration.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingSessionJuration>> update({required VotingSessionJuration entity}) {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_jurations').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(VotingSessionJuration.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) {
    return handleDatabaseCall(() async {
      await _supabase.from('voting_session_jurations').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, VotingSessionJuration>> getById({required String id}) {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_jurations').select().eq('id', id).limit(1).single();
      return Either.right(VotingSessionJuration.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingSessionJuration?>> getNullableById({required String id}) {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_jurations').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? VotingSessionJuration.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<VotingSessionJuration>>> getAll() {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_session_jurations').select();
      return Either.right(res.map((e) => VotingSessionJuration.fromJson(e)).toList(growable: false));
    });
  }
}
