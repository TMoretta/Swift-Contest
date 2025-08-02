import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/database/bundles/auth_bundle.dart';
import 'package:swift_contest/model/database/daos/account_dao.dart';
import 'package:swift_contest/model/database/daos/message_dao.dart';
import 'package:swift_contest/model/database/daos/profile_dao.dart';
import 'package:swift_contest/model/database/entities/account.dart';
import 'package:swift_contest/model/database/entities/profile.dart';
import 'package:swift_contest/model/database/types/contest_role.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, AuthBundle>> getCurrentAccountAuthBundle();

  Future<Either<Failure, Account>> updateCurrentAccountEmail({required String email});

  Future<Either<Failure, Unit>> updateCurrentAccountPassword({required String password});

  Future<Either<Failure, Unit>> deleteCurrentAccount();

  Future<Either<Failure, Unit>> markMessageAsRead({required String messageId});

  Future<Either<Failure, Unit>> deleteMessage({required String messageId});

  Future<Either<Failure, Unit>> deleteAllCurrentAccountMessages();

  Future<Either<Failure, Profile>> updateCurrentProfileFullName({required String fullName});

  Future<Either<Failure, Profile>> updateCurrentProfilePrefRole({required ContestRole prefRole});

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
  final AccountDao _accountDao;
  final ProfileDao _profileDao;
  final MessageDao _messageDao;

  AuthRepositoryImpl({
    required SupabaseClient supabaseClient,
    required AccountDao accountDao,
    required ProfileDao profileDao,
    required MessageDao messageDao,
  })  : _supabase = supabaseClient,
        _accountDao = accountDao,
        _profileDao = profileDao,
        _messageDao = messageDao;

  @override
  Future<Either<Failure, AuthBundle>> getCurrentAccountAuthBundle() async {
    return handleDatabaseCall(
      () async {
        final eitherAccount = await _accountDao.getCurrent();
        if (eitherAccount.isLeft()) {
          return Either.left(eitherAccount.getLeft().toNullable()!);
        }
        final account = eitherAccount.getRight().toNullable()!;

        final eitherProfile = await _profileDao.getById(id: account.id);
        if (eitherProfile.isLeft()) {
          return Either.left(eitherProfile.getLeft().toNullable()!);
        }
        final profile = eitherProfile.getRight().toNullable()!;

        final eitherMessages = await _messageDao.getByAccountId(accountId: account.id);
        if (eitherMessages.isLeft()) {
          return Either.left(eitherMessages.getLeft().toNullable()!);
        }
        final messages = eitherMessages.getRight().toNullable()!;

        return Either.right(AuthBundle(account: account, profile: profile, messages: messages));
      },
    );
  }

  @override
  Future<Either<Failure, Account>> updateCurrentAccountEmail({required String email}) async {
    return handleDatabaseCall(
      () async {
        final eitherAccount =
            await _accountDao.updateCurrent(userAttributes: UserAttributes(email: email));
        if (eitherAccount.isLeft()) {
          return Either.left(eitherAccount.getLeft().toNullable()!);
        }
        return Either.right(eitherAccount.getRight().toNullable()!);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> updateCurrentAccountPassword({required String password}) async {
    return handleDatabaseCall(
      () async {
        final eitherAccount =
            await _accountDao.updateCurrent(userAttributes: UserAttributes(password: password));
        if (eitherAccount.isLeft()) {
          return Either.left(eitherAccount.getLeft().toNullable()!);
        }
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteCurrentAccount() async {
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
        final eitherMessage = await _messageDao.getById(id: messageId);
        if (eitherMessage.isLeft()) {
          return Either.left(eitherMessage.getLeft().toNullable()!);
        }
        final message = eitherMessage.getRight().toNullable()!;

        final eitherUpdate = await _messageDao.update(entity: message.copyWith(isRead: true));
        if (eitherUpdate.isLeft()) {
          return Either.left(eitherUpdate.getLeft().toNullable()!);
        }
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage({required String messageId}) async {
    return handleDatabaseCall(
      () async {
        final eitherDelete = await _messageDao.deleteById(id: messageId);
        if (eitherDelete.isLeft()) {
          return Either.left(eitherDelete.getLeft().toNullable()!);
        }
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteAllCurrentAccountMessages() async {
    return handleDatabaseCall(
      () async {
        final eitherAccount = await _accountDao.getCurrent();
        if (eitherAccount.isLeft()) {
          return Either.left(eitherAccount.getLeft().toNullable()!);
        }
        final account = eitherAccount.getRight().toNullable()!;
        final eitherDelete = await _messageDao.deleteByAccountId(accountId: account.id);
        if (eitherDelete.isLeft()) {
          return Either.left(eitherDelete.getLeft().toNullable()!);
        }
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Profile>> updateCurrentProfileFullName({required String fullName}) async {
    return handleDatabaseCall(
      () async {
        final eitherAccount = await _accountDao.getCurrent();
        if (eitherAccount.isLeft()) {
          return Either.left(eitherAccount.getLeft().toNullable()!);
        }
        final account = eitherAccount.getRight().toNullable()!;

        final eitherProfile = await _profileDao.getById(id: account.id);
        if (eitherProfile.isLeft()) {
          return Either.left(eitherProfile.getLeft().toNullable()!);
        }
        final oldProfile = eitherProfile.getRight().toNullable()!;

        final eitherUpdate =
            await _profileDao.update(entity: oldProfile.copyWith(fullName: fullName));
        if (eitherUpdate.isLeft()) {
          return Either.left(eitherUpdate.getLeft().toNullable()!);
        }
        final newProfile = eitherUpdate.getRight().toNullable()!;
        return Either.right(newProfile);
      },
    );
  }

  @override
  Future<Either<Failure, Profile>> updateCurrentProfilePrefRole({
    required ContestRole prefRole,
  }) async {
    return handleDatabaseCall(
      () async {
        final eitherAccount = await _accountDao.getCurrent();
        if (eitherAccount.isLeft()) {
          return Either.left(eitherAccount.getLeft().toNullable()!);
        }
        final account = eitherAccount.getRight().toNullable()!;

        final eitherProfile = await _profileDao.getById(id: account.id);
        if (eitherProfile.isLeft()) {
          return Either.left(eitherProfile.getLeft().toNullable()!);
        }
        final oldProfile = eitherProfile.getRight().toNullable()!;

        final eitherUpdate =
            await _profileDao.update(entity: oldProfile.copyWith(prefRole: prefRole));
        if (eitherUpdate.isLeft()) {
          return Either.left(eitherUpdate.getLeft().toNullable()!);
        }
        final newProfile = eitherUpdate.getRight().toNullable()!;
        return Either.right(newProfile);
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
        // final account = Account.fromJson(session.user.toJson());
        // if(account.isAdmin) {
        //   await _supabase.auth.signOut();
        //   return Eithlefter.right(Failure('Invalid credentials'));
        // }
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
        await _supabase.auth.signInAnonymously();
        return Either.right(unit);
      },
    );
  }
}
