import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/database/entities/contest_ranking.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/utils/handle_backend_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class ContestRankingDao implements Dao<ContestRanking> {
  Future<Either<Failure, List<ContestRanking>>> getByContestId({required String contestId});
}

class ContestRankingDaoImpl implements ContestRankingDao {
  final SupabaseClient _supabase;

  ContestRankingDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, ContestRanking>> create({required ContestRanking entity}) {
    return handleBackendCall(() async {
      final res = await _supabase.from('contest_rankings').insert(entity.toJson()).select().single();
      return Either.right(ContestRanking.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, ContestRanking>> update({required ContestRanking entity}) {
    return handleBackendCall(() async {
      final res = await _supabase
          .from('contest_rankings')
          .update(entity.toJson())
          .eq('id', entity.id!)
          .select()
          .single();

      return Either.right(ContestRanking.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) {
    return handleBackendCall(() async {
      await _supabase.from('contest_rankings').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, ContestRanking>> getById({required String id}) {
    return handleBackendCall(() async {
      final res = await _supabase.from('contest_rankings').select().eq('id', id).limit(1).single();
      return Either.right(ContestRanking.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, ContestRanking?>> getNullableById({required String id}) {
    return handleBackendCall(() async {
      final res = await _supabase.from('contest_rankings').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? ContestRanking.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<ContestRanking>>> getAll() {
    return handleBackendCall(() async {
      final res = await _supabase.from('contest_rankings').select().order('created_at');
      return Either.right(res.map((e) => ContestRanking.fromJson(e)).toList(growable: false));
    });
  }

  @override
  Future<Either<Failure, List<ContestRanking>>> getByContestId({required String contestId}) {
    return handleBackendCall(() async {
      final res = await _supabase
          .from('contest_rankings')
          .select()
          .eq('contest_id', contestId)
          .order('created_at');
      return Either.right(res.map((e) => ContestRanking.fromJson(e)).toList(growable: false));
    });
  }
}
