import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/db/entities/simple_juror_voting.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class SimpleJurorVotingDao implements Dao<SimpleJurorVoting> {}

class SimpleJurorVotingDaoImpl implements SimpleJurorVotingDao {
  final SupabaseClient _supabase;

  SimpleJurorVotingDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, SimpleJurorVoting>> create({required SimpleJurorVoting entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('simple_juror_votings').insert(entity.toJson()).select().single();
      return Either.right(SimpleJurorVoting.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, SimpleJurorVoting>> update({required SimpleJurorVoting entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('simple_juror_votings').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(SimpleJurorVoting.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('simple_juror_votings').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, SimpleJurorVoting>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('simple_juror_votings').select().eq('id', id).limit(1).single();
      return Either.right(SimpleJurorVoting.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, SimpleJurorVoting?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('simple_juror_votings').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? SimpleJurorVoting.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<SimpleJurorVoting>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('simple_juror_votings').select();
      return Either.right(res.map((e) => SimpleJurorVoting.fromJson(e)).toList(growable: false));
    });
  }
}
