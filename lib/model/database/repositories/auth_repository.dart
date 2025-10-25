import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/database/bundles/account_bundle.dart';
import 'package:swift_contest/model/database/entities/message.dart';
import 'package:swift_contest/model/database/types/contest_role.dart';
import 'package:swift_contest/model/utils/handle_backend_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, AccountBundle?>> getAccountBundle();

  Future<Either<Failure, List<Message>>> getMessages();

  Future<Either<Failure, Stream<List<Message>>>> getMessagesStream();

  // Future<Either<Failure, Account>> updateAccountEmail({required String email});
  //
  // Future<Either<Failure, Unit>> updateAccountPassword({required String password});

  Future<Either<Failure, Unit>> deleteAccount();

  Future<Either<Failure, bool>> checkAccountExists({required String email});

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

  Future<Either<Failure, List<int>>> getLatestApk();
}

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl({
    required SupabaseClient supabaseClient,
  }) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, AccountBundle?>> getAccountBundle() async {
    return handleBackendCall(
      () async {
        final Map<String, dynamic>? res =
            await _supabase.rpc('auth_get_account_bundle').maybeSingle();
        if (res == null) {
          return Either.right(null);
        }
        return Either.right(AccountBundle.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages() async {
    return handleBackendCall(
      () async {
        final List<Map<String, dynamic>> res = await _supabase.rpc('auth_get_messages');
        return Either.right(res.map((e) => Message.fromJson(e)).toList(growable: false));
      },
    );
  }

  @override
  Future<Either<Failure, bool>> checkAccountExists({required String email}) {
    return handleBackendCall(
      () async {
        final bool exists = await _supabase.rpc(
          'auth_check_account_exists',
          params: {'p_email': email},
        );
        return Either.right(exists);
      },
    );
  }

  @override
  Future<Either<Failure, Stream<List<Message>>>> getMessagesStream() async {
    return handleBackendCall(
      () async {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) {
          return Either.left(Failure('User not authenticated to get messages.'));
        }

        final Stream<List<Message>> stream = _supabase
            .from('messages')
            .stream(primaryKey: ['id'])
            .eq('account_id', userId)
            .map((listOfMaps) {
              final messages = listOfMaps.map((e) => Message.fromJson(e)).toList(growable: false);
              messages.sort(
                (a, b) => b.createdAt!.compareTo(a.createdAt!),
              );
              return messages;
            });
        return Either.right(stream);
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
    return handleBackendCall(
      () async {
        final res = await _supabase.functions.invoke('user-delete-account');
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
    return handleBackendCall(
      () async {
        await _supabase.rpc('auth_mark_message_as_read', params: {'p_message_id': messageId});
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage({required String messageId}) async {
    return handleBackendCall(
      () async {
        await _supabase.rpc('auth_delete_message', params: {'p_message_id': messageId});
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteAllAccountMessages() async {
    return handleBackendCall(
      () async {
        await _supabase.rpc('auth_delete_all_account_messages');
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> updateProfileFullName({required String fullName}) async {
    return handleBackendCall(
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
    return handleBackendCall(
      () async {
        await _supabase
            .rpc('auth_update_profile_pref_role', params: {'p_pref_role': prefRole.name});
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return handleBackendCall(
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
    return handleBackendCall(
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
    return handleBackendCall(
      () async {
        // First, check if the account exists.
        final eitherExists = await checkAccountExists(email: email);
        return await eitherExists.fold(
          (failure) => Either.left(failure),
          (exists) async {
            if (!exists) {
              return Either.left(Failure('Account does not exist. Please sign up first.'));
            }
            // If account exists, proceed with sign-in.
            await _supabase.auth.signInWithOtp(email: email, shouldCreateUser: false);
            return Either.right(unit);
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> signUpWithEmail({
    required String email,
    required String fullName,
  }) async {
    return handleBackendCall(
      () async {
        // First, check if the account already exists.
        final eitherExists = await checkAccountExists(email: email);
        return await eitherExists.fold(
          (failure) => Either.left(failure),
          (exists) async {
            if (exists) {
              return Either.left(Failure('An account with this email already exists.'));
            }
            // If account does not exist, proceed with sign-up.
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
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> signInVerifyOtp({
    required String email,
    required String otp,
  }) async {
    return handleBackendCall(
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
    return handleBackendCall(
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
    return handleBackendCall(
      () async {
        await _supabase.auth.signOut();
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> anonSignIn({required String fullName}) {
    return handleBackendCall(
      () async {
        await _supabase.auth.signInAnonymously(data: {'full_name': fullName});
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, List<int>>> getLatestApk() {
    return handleBackendCall(() async {
      // Invoke the Edge Function which acts as a secure proxy to GitHub.
      final response = await _supabase.functions.invoke('get-latest-apk');

      if (response.data is List<int>) {
        return Either.right(response.data as List<int>);
      }

      return Either.left(ServerFailure('Failed to download APK.'));
    });
  }
}
