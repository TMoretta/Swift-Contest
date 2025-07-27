import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/db/entities/juror_vote.dart';
import 'package:swift_contest/utils/failures/failures.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';


abstract interface class JurorVoteDao implements Dao<JurorVote> {}

class JurorVoteDaoImpl implements JurorVoteDao {
  final SupabaseClient _supabase;

  JurorVoteDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, JurorVote>> create({required JurorVote entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('juror_votes').insert(entity.toJson()).select().single();
      return Either.right(JurorVote.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, JurorVote>> update({required JurorVote entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('juror_votes').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(JurorVote.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('juror_votes').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, JurorVote>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('juror_votes').select().eq('id', id).limit(1).single();
      return Either.right(JurorVote.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, JurorVote?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('juror_votes').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? JurorVote.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<JurorVote>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('juror_votes').select();
      return Either.right(res.map((e) => JurorVote.fromJson(e)).toList(growable: false));
    });
  }
}
