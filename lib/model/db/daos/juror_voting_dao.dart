import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/db/entities/juror_voting.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class JurorVotingDao implements Dao<JurorVoting> {}

class JurorVotingDaoImpl implements JurorVotingDao {
  final SupabaseClient _supabase;

  JurorVotingDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, JurorVoting>> create({required JurorVoting entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('juror_votings').insert(entity.toJson()).select().single();
      return Either.right(JurorVoting.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, JurorVoting>> update({required JurorVoting entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('juror_votings').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(JurorVoting.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('juror_votings').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, JurorVoting>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('juror_votings').select().eq('id', id).limit(1).single();
      return Either.right(JurorVoting.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, JurorVoting?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('juror_votings').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? JurorVoting.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<JurorVoting>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('juror_votings').select();
      return Either.right(res.map((e) => JurorVoting.fromJson(e)).toList(growable: false));
    });
  }
}
