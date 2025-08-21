import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/database/bundles/account_bundle.dart';
import 'package:swift_contest/model/database/entities/profile.dart';
import 'package:swift_contest/model/database/types/contest_role.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, AccountBundle?>> getAccountBundle();

  // Future<Either<Failure, Account>> updateAccountEmail({required String email});
  //
  // Future<Either<Failure, Unit>> updateAccountPassword({required String password});

  Future<Either<Failure, Unit>> deleteAccount();

  Future<Either<Failure, Unit>> markMessageAsRead({required String messageId});

  Future<Either<Failure, Unit>> deleteMessage({required String messageId});

  Future<Either<Failure, Unit>> deleteAllAccountMessages();

  Future<Either<Failure, Unit>> updateProfileFullName({required String fullName});

  Future<Either<Failure, Unit>> updateProfilePrefRole({required ContestRole prefRole});

  Future<Either<Failure, Unit>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Either<Failure, Unit>> signInWithEmail({required String email});

  Future<Either<Failure, Unit>> signUpWithEmail({required String email, required String fullName});

  Future<Either<Failure, Unit>> signInVerifyOtp({required String email, required String otp});

  Future<Either<Failure, Unit>> signUpVerifyOtp({required String email, required String otp});

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, Unit>> anonSignIn({required String fullName});
}

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl({
    required SupabaseClient supabaseClient,
  })  : _supabase = supabaseClient;

  @override
  Future<Either<Failure, AccountBundle?>> getAccountBundle() async {
    return handleDatabaseCall(
      () async {
        final Map<String, dynamic>? res = await _supabase.rpc('auth_get_account_bundle').maybeSingle();
        if (res == null) {
          return Either.right(null);
        }
        return Either.right(AccountBundle.fromJson(res));
      },
    );
  }

  // @override
  // Future<Either<Failure, Account>> updateAccountEmail({required String email}) async {
  //   return handleDatabaseCall(
  //     () async {
  //       final eitherAccount =
  //           await _accountDao.updateCurrent(userAttributes: UserAttributes(email: email));
  //       if (eitherAccount.isLeft()) {
  //         return Either.left(eitherAccount.getLeft().toNullable()!);
  //       }
  //       return Either.right(eitherAccount.getRight().toNullable()!);
  //     },
  //   );
  // }
  //
  // @override
  // Future<Either<Failure, Unit>> updateAccountPassword({required String password}) async {
  //   return handleDatabaseCall(
  //     () async {
  //       final eitherAccount =
  //           await _accountDao.updateCurrent(userAttributes: UserAttributes(password: password));
  //       if (eitherAccount.isLeft()) {
  //         return Either.left(eitherAccount.getLeft().toNullable()!);
  //       }
  //       return Either.right(unit);
  //     },
  //   );
  // }

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    return handleDatabaseCall(
      () async {
        final res = await _supabase.functions.invoke('delete-account');
        if (res.status != 200) {
          return Either.left(Failure(res.data.toString()));
        }
        await _supabase.auth.signOut(scope: SignOutScope.global);
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> markMessageAsRead({required String messageId}) async {
    return handleDatabaseCall(
      () async {
        await _supabase.rpc('auth_mark_message_as_read', params: {'p_message_id': messageId});
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage({required String messageId}) async {
    return handleDatabaseCall(
      () async {
        await _supabase.rpc('auth_delete_message', params: {'p_message_id': messageId});
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteAllAccountMessages() async {
    return handleDatabaseCall(
      () async {
        await _supabase.rpc('auth_delete_all_account_messages');
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> updateProfileFullName({required String fullName}) async {
    return handleDatabaseCall(
      () async {
        await _supabase.rpc('auth_update_profile_full_name', params: {'p_full_name': fullName});
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> updateProfilePrefRole({
    required ContestRole prefRole,
  }) async {
    return handleDatabaseCall(
      () async {
        await _supabase.rpc('auth_update_profile_pref_role', params: {'p_pref_role': prefRole.name});
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return handleDatabaseCall(
      () async {
        final response = await _supabase.auth.signInWithPassword(email: email, password: password);
        final session = response.session;
        if (session == null) {
          return Either.left(Failure('No valid session found'));
        }
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return handleDatabaseCall(
      () async {
        final response = await _supabase.auth.signUp(
          email: email,
          password: password,
          data: {
            'full_name': fullName,
          },
        );
        final user = response.user;
        if (user == null) {
          return Either.left(Failure('No valid session found'));
        }
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> signInWithEmail({required String email}) async {
    return handleDatabaseCall(
      () async {
        await _supabase.auth.signInWithOtp(email: email, shouldCreateUser: false);
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> signUpWithEmail({
    required String email,
    required String fullName,
  }) async {
    return handleDatabaseCall(
      () async {
        await _supabase.auth.signInWithOtp(
          shouldCreateUser: true,
          email: email,
          data: {
            'full_name': fullName,
          },
        );
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> signInVerifyOtp({
    required String email,
    required String otp,
  }) async {
    return handleDatabaseCall(
      () async {
        final response = await _supabase.auth.verifyOTP(
          type: OtpType.email,
          email: email,
          token: otp,
        );
        final session = response.session;
        if (session == null) {
          return Either.left(Failure('No valid session found'));
        }
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> signUpVerifyOtp({
    required String email,
    required String otp,
  }) async {
    return handleDatabaseCall(
      () async {
        final response = await _supabase.auth.verifyOTP(
          type: OtpType.signup,
          email: email,
          token: otp,
        );
        final session = response.session;
        if (session == null) {
          return left(Failure('No valid session found'));
        }
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    return handleDatabaseCall(
      () async {
        await _supabase.auth.signOut();
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> anonSignIn({required String fullName}) {
    return handleDatabaseCall(
      () async {
        await _supabase.auth.signInAnonymously(data: {'full_name': fullName});
        return Either.right(unit);
      },
    );
  }
}
