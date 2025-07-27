import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/db/entities/juration.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/model/utils/postgrest_exception_to_failure.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class JurationDao implements Dao<Juration> {
  Future<Either<Failure, List<Juration>>> getByContestId({required String contestId});
}

class JurationDaoImpl implements JurationDao {
  final SupabaseClient _supabase;

  JurationDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Juration>> create({required Juration entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('jurations').insert(entity.toJson()).select().single();
      return Either.right(Juration.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Juration>> update({required Juration entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('jurations').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(Juration.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('jurations').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, Juration>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('jurations').select().eq('id', id).limit(1).single();
      return Either.right(Juration.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Juration?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('jurations').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? Juration.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<Juration>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('jurations').select();
      return Either.right(res.map((e) => Juration.fromJson(e)).toList(growable: false));
    });
  }

  @override
  Future<Either<Failure, List<Juration>>> getByContestId({required String contestId}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('jurations').select().eq('contest_id', contestId).order('created_at');
      return Either.right(res.map((e) => Juration.fromJson(e)).toList(growable: false));
    });
  }
}
