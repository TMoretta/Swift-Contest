import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/database/entities/voting_session.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class VotingSessionDao implements Dao<VotingSession> {

Future<Either<Failure, List<VotingSession>>> getByContestId({required String contestId});
}

class VotingSessionDaoImpl implements VotingSessionDao {
  final SupabaseClient _supabase;

  VotingSessionDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, VotingSession>> create({required VotingSession entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_sessions').insert(entity.toJson()).select().single();
      return Either.right(VotingSession.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingSession>> update({required VotingSession entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_sessions').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(VotingSession.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('voting_sessions').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, VotingSession>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_sessions').select().eq('id', id).limit(1).single();
      return Either.right(VotingSession.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, VotingSession?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_sessions').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? VotingSession.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<VotingSession>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_sessions').select();
      return Either.right(res.map((e) => VotingSession.fromJson(e)).toList(growable: false));
    });
  }

  @override
  Future<Either<Failure, List<VotingSession>>> getByContestId({required String contestId})async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('voting_sessions').select().eq('contest_id', contestId);
      return Either.right(res.map((e) => VotingSession.fromJson(e)).toList(growable: false));
    });
  }
}
