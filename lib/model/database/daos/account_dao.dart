import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/database/entities/account.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class AccountDao {
  Future<Either<Failure, Account>> updateCurrent({required UserAttributes userAttributes});

  Future<Either<Failure, Account>> getCurrent();
}

class AccountDaoImpl implements AccountDao {
  final SupabaseClient _supabase;

  AccountDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Account>> updateCurrent({required UserAttributes userAttributes}) async {
    return handleDatabaseCall(
      () async {
        final res = await _supabase.auth.updateUser(userAttributes);
        return Either.right(Account.fromJson(res.user!.toJson()));
      },
    );
  }

  @override
  Future<Either<Failure, Account>> getCurrent() async {
    return handleDatabaseCall(
      () async {
        final response = await _supabase.auth.getUser();
        return Either.right(Account.fromJson(response.user!.toJson()));
      },
    );
  }
}
