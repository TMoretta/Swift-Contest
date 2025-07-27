import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/db/entities/simple_juror_vote.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class SimpleJurorVoteDao implements Dao<SimpleJurorVote> {}

class SimpleJurorVoteDaoImpl implements SimpleJurorVoteDao {
  final SupabaseClient _supabase;

  SimpleJurorVoteDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, SimpleJurorVote>> create({required SimpleJurorVote entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('simple_juror_votes').insert(entity.toJson()).select().single();
      return Either.right(SimpleJurorVote.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, SimpleJurorVote>> update({required SimpleJurorVote entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('simple_juror_votes').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(SimpleJurorVote.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('simple_juror_votes').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, SimpleJurorVote>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('simple_juror_votes').select().eq('id', id).limit(1).single();
      return Either.right(SimpleJurorVote.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, SimpleJurorVote?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('simple_juror_votes').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? SimpleJurorVote.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<SimpleJurorVote>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('simple_juror_votes').select();
      return Either.right(res.map((e) => SimpleJurorVote.fromJson(e)).toList(growable: false));
    });
  }
}
